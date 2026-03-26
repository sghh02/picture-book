import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:picture_book/app/app.dart';
import 'package:picture_book/app/router.dart';
import 'package:picture_book/features/book/data/book_viewer_local_store.dart';
import 'package:picture_book/features/book/data/books_repository.dart';
import 'package:picture_book/features/book/domain/book.dart';
import 'package:picture_book/features/book/presentation/book_viewer_page.dart';
import 'package:picture_book/features/book/providers/book_viewer_providers.dart';
import 'package:picture_book/features/book/providers/books_providers.dart';
import 'package:picture_book/features/home/presentation/home_page.dart';
import 'package:picture_book/features/home/providers/home_providers.dart';
import 'package:picture_book/features/my_page/presentation/my_page.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    BooksRepository? repository,
    GoRouter? router,
    BookViewerLocalStore? localStore,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (repository != null)
            booksRepositoryProvider.overrideWithValue(repository),
          if (localStore != null)
            bookViewerLocalStoreProvider.overrideWithValue(localStore),
        ],
        child: router == null
            ? const PictureBookApp()
            : MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('app boots into home and navigates to my page', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);

    await tester.tap(find.byKey(HomePage.profileButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('マイページ'), findsOneWidget);
  });

  testWidgets('platform back returns from my page to home', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(HomePage.profileButtonKey));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });

  testWidgets('router factory can start at book viewer', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      router: createAppRouter(initialLocation: '/book/sample-book'),
    );
    await tester.pumpAndSettle();

    expect(find.text('くもの子マルの旅'), findsWidgets);
    expect(find.byKey(BookViewerPage.pageNumberKey), findsOneWidget);
    expect(find.text('1 / 6'), findsOneWidget);
  });

  testWidgets('router factory can start at my page', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, router: createAppRouter(initialLocation: '/my'));
    await tester.pumpAndSettle();

    expect(find.text('マイページ'), findsOneWidget);
  });

  testWidgets('sample book card navigates from home to viewer', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(HomePage.sampleBookCardKey));
    await tester.pumpAndSettle();

    expect(find.text('くもの子マルの旅'), findsWidgets);
  });

  testWidgets('platform back returns from sample book viewer to home', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(HomePage.sampleBookCardKey));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });

  testWidgets('my page home button always returns to home', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, router: createAppRouter(initialLocation: '/my'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(MyPage.homeButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });

  testWidgets('viewer back button always returns to home', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      router: createAppRouter(initialLocation: '/book/sample-book'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(BookViewerPage.backButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });

  testWidgets('viewer home button always returns to home', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      router: createAppRouter(initialLocation: '/book/sample-book'),
    );
    await tester.pumpAndSettle();

    await _advanceViewerToEnd(tester, turns: 8);

    await tester.tap(find.byKey(BookViewerPage.homeButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });

  testWidgets('home shows recommended and ranking books from repository', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('おすすめ'), findsOneWidget);
    expect(find.text('にんきランキング'), findsOneWidget);
    expect(find.text('くもの子マルの旅'), findsWidgets);
    expect(find.text('にじいろのさかな'), findsWidgets);
  });

  testWidgets('age filter updates recommended title and ranking contents', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(HomePage.filterChipKey(HomeAgeFilter.age6Plus)),
    );
    await tester.pumpAndSettle();

    expect(find.text('6さい〜の おすすめ'), findsOneWidget);
    expect(find.text('ほしぞらのひみつ'), findsWidgets);
    expect(find.text('おばけのともだち'), findsWidgets);
    expect(find.text('くもの子マルの旅'), findsNothing);
  });

  testWidgets('ranking item navigates to viewer', (WidgetTester tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(HomePage.rankingItemKey('rainbow-fish')));
    await tester.pumpAndSettle();

    expect(find.text('にじいろのさかな'), findsWidgets);
  });

  testWidgets('viewer page navigation updates reading history', (
    WidgetTester tester,
  ) async {
    final localStore = _MemoryBookViewerLocalStore();

    await pumpApp(
      tester,
      router: createAppRouter(initialLocation: '/book/sample-book'),
      localStore: localStore,
    );
    await tester.pumpAndSettle();

    expect(localStore.history.single.lastPage, 0);

    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;
    controller.jumpToPage(1);
    await tester.pumpAndSettle();

    expect(localStore.history.single.lastPage, 1);

    controller.jumpToPage(2);
    await tester.pumpAndSettle();

    expect(localStore.history.single.lastPage, 2);

    controller.jumpToPage(1);
    await tester.pumpAndSettle();

    expect(localStore.history.single.lastPage, 1);
  });

  testWidgets('viewer like state persists across rebuild and end screen', (
    WidgetTester tester,
  ) async {
    final localStore = _MemoryBookViewerLocalStore();

    await pumpApp(
      tester,
      router: createAppRouter(initialLocation: '/book/sample-book'),
      localStore: localStore,
    );
    await tester.pumpAndSettle();

    expect(localStore.likedBookIds, isEmpty);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    final likeButton = tester.widget<IconButton>(
      find.byKey(BookViewerPage.likeButtonKey),
    );
    likeButton.onPressed!.call();
    await tester.pumpAndSettle();

    expect(localStore.likedBookIds, {'sample-book'});
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await pumpApp(
      tester,
      router: createAppRouter(initialLocation: '/book/sample-book'),
      localStore: localStore,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await _advanceViewerToEnd(tester, turns: 8);

    expect(find.byKey(BookViewerPage.endLikeButtonKey), findsOneWidget);
    expect(find.text('いいね済み'), findsOneWidget);
  });

  testWidgets('viewer overlay auto hides after timeout', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      router: createAppRouter(initialLocation: '/book/sample-book'),
      localStore: _MemoryBookViewerLocalStore(),
    );
    await tester.pumpAndSettle();

    var overlay = tester.widget<AnimatedOpacity>(
      find.byKey(BookViewerPage.overlayKey),
    );
    expect(overlay.opacity, 1);

    await tester.pump(const Duration(seconds: 4));

    overlay = tester.widget<AnimatedOpacity>(
      find.byKey(BookViewerPage.overlayKey),
    );
    expect(overlay.opacity, 0);
  });

  testWidgets('viewer reaches end screen and returns home', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      router: createAppRouter(initialLocation: '/book/sample-book'),
      localStore: _MemoryBookViewerLocalStore(),
    );
    await tester.pumpAndSettle();

    await _advanceViewerToEnd(tester, turns: 8);

    expect(find.byKey(BookViewerPage.endScreenKey), findsOneWidget);
    expect(find.text('おしまい'), findsOneWidget);

    await tester.tap(find.text('ホームにもどる').last);
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });

  testWidgets('failed books load shows retry action', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, repository: const _FailingBooksRepository());
    await tester.pumpAndSettle();

    expect(find.text('えほんを よみこめませんでした'), findsOneWidget);
    expect(find.byKey(HomePage.retryButtonKey), findsOneWidget);
  });

  testWidgets('empty filter result shows empty state', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, repository: _SingleAgeRepository());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(HomePage.filterChipKey(HomeAgeFilter.age6Plus)),
    );
    await tester.pumpAndSettle();

    expect(find.text('この ねんれいの えほんは まだ ありません'), findsOneWidget);
  });

  testWidgets('loading state shows skeleton placeholders', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, repository: const _DelayedBooksRepository());
    await tester.pump();

    expect(find.text('おすすめ'), findsOneWidget);
    expect(find.byKey(HomePage.loadingStateKey), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });
}

class _SingleAgeRepository implements BooksRepository {
  @override
  Future<List<Book>> fetchPublishedBooks() async {
    return [
      Book(
        bookId: 'only-young',
        title: const LocalizedText(ja: 'あかちゃんのうた'),
        description: const LocalizedText(ja: 'やさしい こもりうた'),
        authorName: 'ねむり工房',
        coverUrl: '',
        ageGroup: BookAgeGroup.age0To2,
        pageCount: 8,
        likeCount: 12,
        viewCount: 30,
        status: BookStatus.published,
        pages: const [],
        createdAt: DateTime(2026, 3, 10),
        updatedAt: DateTime(2026, 3, 10),
      ),
    ];
  }
}

class _DelayedBooksRepository implements BooksRepository {
  const _DelayedBooksRepository();

  @override
  Future<List<Book>> fetchPublishedBooks() {
    return Future<List<Book>>.delayed(
      const Duration(seconds: 1),
      () => const [],
    );
  }
}

class _FailingBooksRepository implements BooksRepository {
  const _FailingBooksRepository();

  @override
  Future<List<Book>> fetchPublishedBooks() {
    return Future<List<Book>>.error(Exception('failed'));
  }
}

class _MemoryBookViewerLocalStore implements BookViewerLocalStore {
  Set<String> likedBookIds = <String>{};
  List<ReadingHistoryEntry> history = const <ReadingHistoryEntry>[];

  @override
  Future<List<ReadingHistoryEntry>> loadReadingHistory() async => history;

  @override
  Future<Set<String>> loadLikedBookIds() async => likedBookIds;

  @override
  Future<void> recordHistory({
    required String bookId,
    required int lastPage,
    required DateTime readAt,
  }) async {
    history = [
      ReadingHistoryEntry(bookId: bookId, readAt: readAt, lastPage: lastPage),
      for (final entry in history)
        if (entry.bookId != bookId) entry,
    ];
  }

  @override
  Future<Set<String>> toggleLike(String bookId) async {
    final next = Set<String>.from(likedBookIds);
    if (!next.add(bookId)) {
      next.remove(bookId);
    }
    likedBookIds = next;
    return likedBookIds;
  }
}

Future<void> _advanceViewerToEnd(
  WidgetTester tester, {
  required int turns,
}) async {
  final controller = tester.widget<PageView>(find.byType(PageView)).controller!;

  for (var index = 0; index < turns; index++) {
    if (find.byKey(BookViewerPage.endScreenKey).evaluate().isNotEmpty) {
      return;
    }
    controller.jumpToPage(index + 1);
    await tester.pumpAndSettle();
  }
}
