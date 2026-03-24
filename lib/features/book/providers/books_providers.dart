import 'package:picture_book/features/book/data/books_repository.dart';
import 'package:picture_book/features/book/data/mock_books_repository.dart';
import 'package:picture_book/features/book/domain/book.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'books_providers.g.dart';

@Riverpod(keepAlive: true)
BooksRepository booksRepository(Ref ref) {
  return const MockBooksRepository();
}

@Riverpod(keepAlive: true)
Future<List<Book>> books(Ref ref) async {
  final repository = ref.watch(booksRepositoryProvider);
  return repository.fetchPublishedBooks();
}
