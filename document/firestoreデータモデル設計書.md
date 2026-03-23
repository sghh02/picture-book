# えほんのもり - Firestore データモデル設計書

## 概要

Phase 0（MVP）のFirestoreデータモデル。4コレクション構成。
サブコレクションは使用せず、フラットなコレクション設計でシンプルに保つ。

---

## コレクション一覧

| コレクション | 用途 | ドキュメント数の目安（Phase 0） |
|---|---|---|
| `users` | ユーザー情報 | 〜数百 |
| `books` | 絵本データ（ページ含む） | 20〜30冊 |
| `likes` | いいね記録 | ユーザー数 × 数冊 |
| `history` | 閲覧履歴 | ユーザー数 × 数冊 |

---

## 1. users/{uid}

Firebase AuthのUIDをドキュメントIDとして使用。

```
{
  uid: string,           // Firebase Auth UID（= ドキュメントID）
  name: string,          // 表示名（例: "ゲスト"）
  email: string,         // メールアドレス
  avatarUrl: string | null,  // プロフィール画像URL（R2）
  role: string,          // "user" | "admin"
  createdAt: timestamp   // 登録日時
}
```

### インデックス
- なし（UIDで直接アクセス）

### Security Rules
- 本人のみ読み書き可能
- `role` フィールドはCloud Functionsからのみ変更可能

---

## 2. books/{bookId}

1絵本 = 1ドキュメント。ページデータは `pages` 配列に格納。

```
{
  bookId: string,        // 自動生成ID（= ドキュメントID）
  title: {               // 多言語対応タイトル
    ja: string,          //   日本語（必須）
    en: string | null    //   英語（任意、Phase 1以降）
  },
  description: {         // 多言語対応あらすじ
    ja: string,
    en: string | null
  },
  authorName: string,    // 作者名（Phase 0は運営名義）
  coverUrl: string,      // 表紙画像URL（R2）
  ageGroup: string,      // "0-2" | "3-5" | "6+"
  pageCount: number,     // ページ数
  likeCount: number,     // いいね数（非正規化）
  viewCount: number,     // 閲覧数（非正規化）
  status: string,        // "draft" | "published"
  pages: [               // ページ配列（表紙は含まない）
    {
      imageUrl: string,            // ページ画像URL（R2）
      text: {                      // テキスト（任意、nullならテキスト焼き込み画像）
        ja: string | null,
        en: string | null
      } | null,
      textPosition: string | null  // "top" | "bottom" | "center" | null
    }
  ],
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### インデックス
- `status` + `createdAt`（DESC）→ 新着一覧
- `status` + `likeCount`（DESC）→ ランキング
- `status` + `ageGroup` + `likeCount`（DESC）→ 年齢別ランキング

### Security Rules
- 全ユーザーが `status == "published"` の絵本を読み取り可能
- `role == "admin"` のユーザーのみ作成・編集可能

### 設計メモ
- `pages` を配列にすることで、1回のreadで絵本全データを取得可能
- `likeCount` / `viewCount` は非正規化。Cloud Functionsトリガーで同期
- `text` がnullのページはテキスト込み画像として扱う
- `text` があるページはアプリ側でテキストをオーバーレイ表示
- Phase 1で `text` に言語を追加するだけで多言語対応可能

---

## 3. likes/{自動ID}

ユーザーが絵本にいいねした記録。

```
{
  userId: string,        // users.uid への参照
  bookId: string,        // books.bookId への参照
  createdAt: timestamp   // いいね日時
}
```

### インデックス
- `userId` + `bookId`（ユニーク制約をSecurity Rulesで実現）
- `bookId` + `createdAt`（DESC）→ 絵本のいいね一覧

### Security Rules
- 本人のみ作成・削除可能
- 同じ `userId` + `bookId` の組み合わせは1件のみ許可
- 作成時にCloud Functionsで `books.likeCount` を +1、削除時に -1

---

## 4. history/{自動ID}

ユーザーの閲覧履歴。1ユーザー × 1絵本 = 1レコード（上書き更新）。

```
{
  userId: string,        // users.uid への参照
  bookId: string,        // books.bookId への参照
  lastPage: number,      // 最後に読んだページ番号（0始まり）
  readAt: timestamp      // 最終閲覧日時
}
```

### インデックス
- `userId` + `readAt`（DESC）→ 閲覧履歴一覧（新しい順）
- `userId` + `bookId`（ユニーク）→ 既存レコード検索用

### Security Rules
- 本人のみ読み書き可能
- 同じ `userId` + `bookId` の既存レコードがあれば上書き更新

### 設計メモ
- `lastPage` を保存することで「つづきから読む」機能をPhase 1で追加可能
- `readAt` を更新することで最新の閲覧順にソートできる

---

## Cloud Functions トリガー

### onLikeCreated
- トリガー: `likes` コレクションにドキュメント作成時
- 処理: 対象 `books.likeCount` を +1

### onLikeDeleted
- トリガー: `likes` コレクションからドキュメント削除時
- 処理: 対象 `books.likeCount` を -1

### onHistoryWritten
- トリガー: `history` コレクションにドキュメント作成/更新時
- 処理: 対象 `books.viewCount` を +1（作成時のみ）

---

## 画像保存先（Cloudflare R2）

```
バケット構成:
ehonnomori/
  covers/
    {bookId}.webp          # 表紙画像
  pages/
    {bookId}/
      {pageNumber}.webp    # ページ画像（001.webp, 002.webp, ...）
  avatars/
    {uid}.webp             # ユーザーアバター
```

### 画像仕様
- フォーマット: WebP（圧縮効率が高い）
- 表紙: 600×800px 推奨
- ページ: 1200×1600px 推奨（タブレット対応）
- アバター: 200×200px

### アップロードフロー
1. 管理画面から画像選択
2. Cloud Functionsで R2 Presigned URL を発行
3. クライアントから直接 R2 にアップロード
4. URLをFirestoreに保存

---

## Phase 1 以降の拡張予定

| 追加コレクション | 用途 |
|---|---|
| `follows` | クリエイターのフォロー関係 |
| `subscriptions` | サブスク課金状態（RevenueCat連携） |
| `comments` | 絵本へのコメント |
| `children` | 子どもプロフィール（Familyプラン用） |

| 既存コレクションの拡張 | 内容 |
|---|---|
| `books` に `authorUid` 追加 | クリエイター投稿対応 |
| `books.pages.text` に言語追加 | 多言語対応（en, zh, ko 等） |
| `users` に `subscriptionTier` 追加 | Free / Standard / Family |
| `history` に `readCount` 追加 | 読んだ回数の記録 |
