import 'dart:async';

import 'package:picture_book/features/book/data/books_repository.dart';
import 'package:picture_book/features/book/data/mock_books.dart';
import 'package:picture_book/features/book/domain/book.dart';

class MockBooksRepository implements BooksRepository {
  const MockBooksRepository();

  @override
  Future<List<Book>> fetchPublishedBooks() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    return mockBooks
        .where((book) => book.status == BookStatus.published)
        .toList(growable: false);
  }
}
