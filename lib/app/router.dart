import 'package:go_router/go_router.dart';
import 'package:picture_book/features/book/presentation/book_viewer_page.dart';
import 'package:picture_book/features/home/presentation/home_page.dart';
import 'package:picture_book/features/my_page/presentation/my_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

abstract final class AppRouteName {
  static const home = 'home';
  static const bookViewer = 'bookViewer';
  static const myPage = 'myPage';
}

GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        name: AppRouteName.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/book/:bookId',
        name: AppRouteName.bookViewer,
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return BookViewerPage(bookId: bookId);
        },
      ),
      GoRoute(
        path: '/my',
        name: AppRouteName.myPage,
        builder: (context, state) => const MyPage(),
      ),
    ],
  );
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return createAppRouter();
}
