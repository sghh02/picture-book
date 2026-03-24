import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:picture_book/app/router.dart';
import 'package:picture_book/features/book/domain/book.dart';
import 'package:picture_book/features/home/presentation/home_keys.dart';
import 'package:picture_book/features/home/presentation/widgets/home_book_cover.dart';
import 'package:picture_book/features/home/providers/home_providers.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
    required this.filter,
    required this.recommendedBooks,
    required this.rankedBooks,
    required this.onFilterSelected,
  });

  final HomeAgeFilter filter;
  final List<Book> recommendedBooks;
  final List<Book> rankedBooks;
  final ValueChanged<HomeAgeFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _horizontalPadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(padding: horizontalPadding, title: 'ねんれいフィルター'),
        const Gap(12),
        HomeAgeFilterChips(
          selectedFilter: filter,
          onSelected: onFilterSelected,
          horizontalPadding: horizontalPadding,
        ),
        const Gap(28),
        _SectionTitle(
          padding: horizontalPadding,
          title: filter.recommendedTitle,
        ),
        const Gap(12),
        HomeRecommendedCarousel(
          books: recommendedBooks,
          horizontalPadding: horizontalPadding,
        ),
        const Gap(28),
        _RankingSectionTitle(horizontalPadding: horizontalPadding),
        const Gap(12),
        HomeRankingList(
          books: rankedBooks,
          horizontalPadding: horizontalPadding,
        ),
      ],
    );
  }
}

class HomeAgeFilterChips extends StatelessWidget {
  const HomeAgeFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
    required this.horizontalPadding,
  });

  final HomeAgeFilter selectedFilter;
  final ValueChanged<HomeAgeFilter> onSelected;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = HomeAgeFilter.values[index];

          return _FilterChip(
            key: homeFilterChipKey(filter),
            label: filter.label,
            selected: selectedFilter == filter,
            onTap: () => onSelected(filter),
          );
        },
        separatorBuilder: (context, index) => const Gap(8),
        itemCount: HomeAgeFilter.values.length,
      ),
    );
  }
}

class HomeRecommendedCarousel extends StatelessWidget {
  const HomeRecommendedCarousel({
    super.key,
    required this.books,
    required this.horizontalPadding,
  });

  final List<Book> books;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final cardWidth = _recommendedCardWidth(context);
    final coverSize = _recommendedCardHeight(context);

    return SizedBox(
      height: coverSize + 64,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final book = books[index];

          return SizedBox(
            width: cardWidth,
            child: _RecommendedBookCard(book: book),
          );
        },
        separatorBuilder: (context, index) => const Gap(12),
        itemCount: books.length,
      ),
    );
  }
}

class HomeRankingList extends StatelessWidget {
  const HomeRankingList({
    super.key,
    required this.books,
    required this.horizontalPadding,
  });

  final List<Book> books;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          for (var index = 0; index < books.length; index++)
            _RankingListItem(book: books[index], rank: index + 1),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.padding});

  final String title;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _RankingSectionTitle extends StatelessWidget {
  const _RankingSectionTitle({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFE8A87C)),
          const Gap(6),
          Text(
            'にんきランキング',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? colorScheme.primary : const Color(0xFFF0E6DC),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _RecommendedBookCard extends StatelessWidget {
  const _RecommendedBookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final cardHeight = _recommendedCardHeight(context);

    return GestureDetector(
      key: book.bookId == 'sample-book' ? homeSampleBookCardKey : null,
      onTap: () => _openBook(context, book),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: HomeBookCover(book: book, size: cardHeight),
          ),
          const Gap(8),
          Text(
            book.titleJa,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(4),
          Text(
            book.authorName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RankingListItem extends StatelessWidget {
  const _RankingListItem({required this.book, required this.rank});

  final Book book;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final thumbWidth = _rankingThumbnailWidth(context);
    final thumbHeight = _rankingThumbnailHeight(context);

    return InkWell(
      key: homeRankingItemKey(book.bookId),
      onTap: () => _openBook(context, book),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _RankBadge(rank: rank),
            const Gap(12),
            SizedBox(
              width: thumbWidth,
              height: thumbHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Align(
                  alignment: Alignment.center,
                  child: HomeBookCover(book: book, size: thumbWidth),
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.titleJa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    book.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Gap(12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 16,
                  color: Color(0xFF8B7B6B),
                ),
                const Gap(4),
                Text('${book.likeCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (rank) {
      1 => const Color(0xFFE8A87C),
      2 => const Color(0xFFB8E0D2),
      3 => const Color(0xFFFDDCB5),
      _ => const Color(0xFFF0E6DC),
    };

    final foregroundColor = rank <= 3 ? Colors.white : const Color(0xFF8B7B6B);

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

void _openBook(BuildContext context, Book book) {
  context.pushNamed(
    AppRouteName.bookViewer,
    pathParameters: {'bookId': book.bookId},
  );
}

double _horizontalPadding(BuildContext context) {
  return _isTablet(context) ? 28 : 16;
}

double _recommendedCardWidth(BuildContext context) {
  return _isTablet(context) ? 150 : 120;
}

double _recommendedCardHeight(BuildContext context) {
  return _isTablet(context) ? 170 : 140;
}

double _rankingThumbnailWidth(BuildContext context) {
  return _isTablet(context) ? 56 : 48;
}

double _rankingThumbnailHeight(BuildContext context) {
  return _isTablet(context) ? 64 : 56;
}

bool _isTablet(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= 600;
}
