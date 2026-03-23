import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picture_book/app/app.dart';
import 'package:picture_book/app/router.dart';
import 'package:picture_book/features/book/presentation/book_viewer_page.dart';
import 'package:picture_book/features/home/presentation/home_page.dart';
import 'package:picture_book/features/my_page/presentation/my_page.dart';

void main() {
  testWidgets('app boots into home and navigates to my page',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PictureBookApp()));
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);

    await tester.tap(find.byKey(HomePage.profileButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('マイページ'), findsOneWidget);
  });

  testWidgets('platform back returns from my page to home',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PictureBookApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(HomePage.profileButtonKey));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });

  testWidgets('router factory can start at book viewer',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: createAppRouter(initialLocation: '/book/sample-book'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('sample-book'), findsOneWidget);
  });

  testWidgets('router factory can start at my page',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: createAppRouter(initialLocation: '/my'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('マイページ'), findsOneWidget);
  });

  testWidgets('sample book card navigates from home to viewer',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PictureBookApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(HomePage.sampleBookCardKey));
    await tester.pumpAndSettle();

    expect(find.text('sample-book'), findsOneWidget);
  });

  testWidgets('platform back returns from sample book viewer to home',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PictureBookApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(HomePage.sampleBookCardKey));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });

  testWidgets('my page home button always returns to home',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: createAppRouter(initialLocation: '/my'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(MyPage.homeButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });

  testWidgets('viewer back button always returns to home',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: createAppRouter(initialLocation: '/book/sample-book'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(BookViewerPage.backButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });

  testWidgets('viewer home button always returns to home',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: createAppRouter(initialLocation: '/book/sample-book'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(BookViewerPage.homeButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('えほんのもり'), findsOneWidget);
  });
}
