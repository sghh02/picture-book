import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReadingHistoryEntry {
  const ReadingHistoryEntry({
    required this.bookId,
    required this.readAt,
    required this.lastPage,
  });

  final String bookId;
  final DateTime readAt;
  final int lastPage;

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'readAt': readAt.toUtc().toIso8601String(),
      'lastPage': lastPage,
    };
  }

  static ReadingHistoryEntry fromJson(Map<String, dynamic> json) {
    return ReadingHistoryEntry(
      bookId: json['bookId'] as String,
      readAt: DateTime.parse(json['readAt'] as String).toUtc(),
      lastPage: json['lastPage'] as int,
    );
  }
}

abstract class BookViewerLocalStore {
  Future<Set<String>> loadLikedBookIds();

  Future<Set<String>> toggleLike(String bookId);

  Future<List<ReadingHistoryEntry>> loadReadingHistory();

  Future<void> recordHistory({
    required String bookId,
    required int lastPage,
    required DateTime readAt,
  });
}

class SharedPreferencesBookViewerLocalStore implements BookViewerLocalStore {
  static const likedBookIdsKey = 'liked_book_ids';
  static const readingHistoryKey = 'reading_history';

  Future<void> _historyWriteQueue = Future<void>.value();

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  @override
  Future<Set<String>> loadLikedBookIds() async {
    final prefs = await _prefs();
    final likedIds = prefs.getStringList(likedBookIdsKey) ?? const <String>[];
    return likedIds.toSet();
  }

  @override
  Future<Set<String>> toggleLike(String bookId) async {
    final prefs = await _prefs();
    final likedIds = await loadLikedBookIds();

    if (!likedIds.add(bookId)) {
      likedIds.remove(bookId);
    }

    await prefs.setStringList(
      likedBookIdsKey,
      likedIds.toList(growable: false),
    );

    return likedIds;
  }

  @override
  Future<List<ReadingHistoryEntry>> loadReadingHistory() async {
    final prefs = await _prefs();
    final rawItems = prefs.getStringList(readingHistoryKey) ?? const <String>[];

    final entries = <ReadingHistoryEntry>[];
    for (final rawItem in rawItems) {
      try {
        final decoded = jsonDecode(rawItem) as Map<String, dynamic>;
        entries.add(ReadingHistoryEntry.fromJson(decoded));
      } catch (_) {
        // Ignore malformed persisted entries and keep the rest.
      }
    }

    return entries;
  }

  @override
  Future<void> recordHistory({
    required String bookId,
    required int lastPage,
    required DateTime readAt,
  }) async {
    _historyWriteQueue = _historyWriteQueue.catchError((_) {}).then((_) async {
      final prefs = await _prefs();
      final currentEntries = await loadReadingHistory();
      final updatedEntries = <ReadingHistoryEntry>[
        ReadingHistoryEntry(
          bookId: bookId,
          lastPage: lastPage,
          readAt: readAt.toUtc(),
        ),
        for (final entry in currentEntries)
          if (entry.bookId != bookId) entry,
      ];

      await prefs.setStringList(
        readingHistoryKey,
        updatedEntries
            .map((entry) => jsonEncode(entry.toJson()))
            .toList(growable: false),
      );
    });

    await _historyWriteQueue;
  }
}
