# えほんのもり - Firestore データモデル設計書

## 概要

Phase 0（MVP）のFirestoreデータモデル。
Phase 0 では Firestore を閲覧用の `books` コレクション取得に限定し、
いいねと閲覧履歴はローカル保存で扱う。

---

## コレクション一覧

| コレクション | 用途 | ドキュメント数の目安（Phase 0） |
|---|---|---|
| `books` | 絵本データ（ページ含む） | 20〜30冊 |

---

## 1. books/{bookId}

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
- 運営は Firebase Console から直接作成・編集する

### 設計メモ
- `pages` を配列にすることで、1回のreadで絵本全データを取得可能
- `likeCount` / `viewCount` は Phase 0 では運営が手動管理する
- `text` がnullのページはテキスト込み画像として扱う
- `text` があるページはアプリ側でテキストをオーバーレイ表示
- Phase 1で `text` に言語を追加するだけで多言語対応可能

---

## 2. ローカル保存データ（Phase 0）

### liked_book_ids

```
[
  "book001",
  "book003",
  "book007"
]
```

- 保存先: `shared_preferences` または `hive`
- 用途: いいね済み bookId の保持

### reading_history

```
[
  {
    "bookId": "book001",
    "readAt": "2026-04-01T10:30:00Z",
    "lastPage": 5
  }
]
```

- 保存先: `shared_preferences` または `hive`
- 用途: 閲覧履歴と最終ページ位置の保持
- 重複: 同一 `bookId` は1件のみ保持し、再閲覧時に上書き更新する

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
```

### 画像仕様
- フォーマット: WebP（圧縮効率が高い）
- 表紙: 600×800px 推奨
- ページ: 1200×1600px 推奨（タブレット対応）

### アップロードフロー
1. 絵本画像をローカルで用意
2. Cloudflare R2 ダッシュボードまたは CLI でアップロード
3. Firebase Console から `books` ドキュメントを作成
4. `coverUrl` / `pages.imageUrl` にアップロード済み URL を保存

---

## Phase 1 以降の拡張予定

| 追加コレクション | 用途 |
|---|---|
| `users` | 認証導入後のユーザー情報 |
| `likes` | サーバー保存のいいね記録 |
| `history` | サーバー保存の閲覧履歴 |
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
| Cloud Functions | いいね / 履歴のサーバー同期と集計に利用 |
