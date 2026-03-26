import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_book/features/book/data/book_viewer_local_store.dart';
import 'package:picture_book/features/book/domain/book.dart';
import 'package:picture_book/features/book/providers/books_providers.dart';

final bookViewerLocalStoreProvider = Provider<BookViewerLocalStore>((ref) {
  return SharedPreferencesBookViewerLocalStore();
});

final bookByIdProvider = Provider.family<AsyncValue<Book?>, String>((
  ref,
  bookId,
) {
  final booksAsync = ref.watch(booksProvider);
  return booksAsync.whenData((books) {
    for (final book in books) {
      if (book.bookId == bookId) {
        return book;
      }
    }
    return null;
  });
});

class LikedBookIdsController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final store = ref.watch(bookViewerLocalStoreProvider);
    return store.loadLikedBookIds();
  }

  Future<void> toggleLike(String bookId) async {
    final store = ref.read(bookViewerLocalStoreProvider);
    final current = await future;
    state = AsyncData(current);

    final updated = await store.toggleLike(bookId);
    state = AsyncData(updated);
  }
}

final likedBookIdsProvider =
    AsyncNotifierProvider<LikedBookIdsController, Set<String>>(
      LikedBookIdsController.new,
    );
