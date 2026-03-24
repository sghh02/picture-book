import 'package:picture_book/features/book/domain/book.dart';
import 'package:picture_book/features/book/providers/books_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

enum HomeAgeFilter {
  all('すべて'),
  age0To2('0〜2さい'),
  age3To5('3〜5さい'),
  age6Plus('6さい〜');

  const HomeAgeFilter(this.label);

  final String label;

  String get recommendedTitle {
    if (this == HomeAgeFilter.all) {
      return 'おすすめ';
    }

    return '$labelの おすすめ';
  }

  bool matches(Book book) {
    return switch (this) {
      HomeAgeFilter.all => true,
      HomeAgeFilter.age0To2 => book.ageGroup == BookAgeGroup.age0To2,
      HomeAgeFilter.age3To5 => book.ageGroup == BookAgeGroup.age3To5,
      HomeAgeFilter.age6Plus => book.ageGroup == BookAgeGroup.age6Plus,
    };
  }
}

@Riverpod(keepAlive: true)
class SelectedAgeFilter extends _$SelectedAgeFilter {
  @override
  HomeAgeFilter build() => HomeAgeFilter.all;

  void select(HomeAgeFilter filter) {
    state = filter;
  }
}

@Riverpod(keepAlive: true)
List<Book> filteredBooks(Ref ref) {
  final books = ref.watch(booksProvider).asData?.value ?? const <Book>[];
  final filter = ref.watch(selectedAgeFilterProvider);

  return books.where(filter.matches).toList(growable: false);
}

@Riverpod(keepAlive: true)
List<Book> recommendedBooks(Ref ref) {
  final books = ref.watch(filteredBooksProvider).toList(growable: false)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return books.take(5).toList(growable: false);
}

@Riverpod(keepAlive: true)
List<Book> rankedBooks(Ref ref) {
  final books = ref.watch(filteredBooksProvider).toList(growable: false)
    ..sort((a, b) => b.likeCount.compareTo(a.likeCount));

  return books;
}
