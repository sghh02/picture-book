import 'package:picture_book/features/book/domain/book.dart';

abstract class BooksRepository {
  Future<List<Book>> fetchPublishedBooks();
}
