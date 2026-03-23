import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picture_book/app/router.dart';

class BookViewerPage extends StatelessWidget {
  const BookViewerPage({
    super.key,
    required this.bookId,
  });

  static const backButtonKey = Key('viewer.backButton');
  static const homeButtonKey = Key('viewer.homeButton');

  final String bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton.filledTonal(
                key: backButtonKey,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                    return;
                  }
                  context.goNamed(AppRouteName.home);
                },
                icon: const Icon(Icons.arrow_back),
                tooltip: 'ホームへ戻る',
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFF0E6), Color(0xFFFFF9F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 72,
                          color: Color(0xFFC4825A),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Book ID',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bookId,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '全画面ビューア本体は次のステップで実装します。',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  key: homeButtonKey,
                  onPressed: () => context.goNamed(AppRouteName.home),
                  child: const Text('ホームにもどる'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
