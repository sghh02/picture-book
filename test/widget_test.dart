import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:picture_book/app/app.dart';
import 'package:picture_book/app/router.dart';
import 'package:picture_book/features/book/data/books_repository.dart';
import 'package:picture_book/features/book/presentation/book_viewer_page.dart';
import 'package:picture_book/features/book/providers/books_providers.dart';
import 'package:picture_book/features/book/domain/book.dart';
import 'package:picture_book/features/home/presentation/home_page.dart';
import 'package:picture_book/features/home/providers/home_providers.dart';
import 'package:picture_book/features/my_page/presentation/my_page.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    BooksRepository? repository,
    GoRouter? router,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (repository != null)
            booksRepositoryProvider.overrideWithValue(repository),
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

    expect(find.text('sample-book'), findsOneWidget);
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

    expect(find.text('sample-book'), findsOneWidget);
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

    expect(find.text('rainbow-fish'), findsOneWidget);
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
