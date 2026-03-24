import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:picture_book/app/router.dart';
import 'package:picture_book/features/book/data/mock_books.dart';
import 'package:picture_book/features/book/providers/books_providers.dart';
import 'package:picture_book/features/home/presentation/home_keys.dart';
import 'package:picture_book/features/home/presentation/widgets/home_content.dart';
import 'package:picture_book/features/home/presentation/widgets/home_state_panels.dart';
import 'package:picture_book/features/home/providers/home_providers.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const profileButtonKey = homeProfileButtonKey;
  static const sampleBookCardKey = homeSampleBookCardKey;
  static const retryButtonKey = homeRetryButtonKey;
  static const loadingStateKey = Key('home.loading');

  static Key filterChipKey(HomeAgeFilter filter) => homeFilterChipKey(filter);

  static Key rankingItemKey(String bookId) => homeRankingItemKey(bookId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    final selectedFilter = ref.watch(selectedAgeFilterProvider);
    final recommendedBooks = ref.watch(recommendedBooksProvider);
    final rankedBooks = ref.watch(rankedBooksProvider);
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? 28.0
        : 16.0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'えほんのもり',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gap(4),
                        Text('すてきな えほんに であおう'),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    key: profileButtonKey,
                    onPressed: () => context.pushNamed(AppRouteName.myPage),
                    icon: const Icon(Icons.person_outline),
                    tooltip: 'マイページ',
                  ),
                ],
              ),
            ),
            const Gap(24),
            booksAsync.when(
              loading: () => const _HomeLoadingContent(),
              error: (error, stackTrace) => Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: HomeErrorPanel(
                  buttonKey: retryButtonKey,
                  onRetry: () => ref.invalidate(booksProvider),
                ),
              ),
              data: (_) {
                if (rankedBooks.isEmpty) {
                  return Column(
                    children: [
                      HomeContent(
                        filter: selectedFilter,
                        recommendedBooks: recommendedBooks,
                        rankedBooks: rankedBooks,
                        onFilterSelected: ref
                            .read(selectedAgeFilterProvider.notifier)
                            .select,
                      ),
                      const Gap(20),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: HomeEmptyPanel(),
                      ),
                    ],
                  );
                }

                return HomeContent(
                  filter: selectedFilter,
                  recommendedBooks: recommendedBooks,
                  rankedBooks: rankedBooks,
                  onFilterSelected: ref
                      .read(selectedAgeFilterProvider.notifier)
                      .select,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeLoadingContent extends StatelessWidget {
  const _HomeLoadingContent();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      key: HomePage.loadingStateKey,
      enabled: true,
      child: HomeContent(
        filter: HomeAgeFilter.all,
        onFilterSelected: (_) {},
        recommendedBooks: mockBooks.take(5).toList(growable: false),
        rankedBooks: mockBooks.toList(growable: false),
      ),
    );
  }
}
