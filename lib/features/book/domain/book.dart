enum BookStatus {
  draft('draft'),
  published('published');

  const BookStatus(this.firestoreValue);

  final String firestoreValue;
}

enum BookAgeGroup {
  age0To2('0-2', '0〜2さい'),
  age3To5('3-5', '3〜5さい'),
  age6Plus('6+', '6さい〜');

  const BookAgeGroup(this.firestoreValue, this.label);

  final String firestoreValue;
  final String label;
}

enum BookTextPosition {
  top('top'),
  bottom('bottom'),
  center('center');

  const BookTextPosition(this.firestoreValue);

  final String firestoreValue;
}

class LocalizedText {
  const LocalizedText({required this.ja, this.en});

  final String ja;
  final String? en;

  String preferred() => ja;
}

class BookPage {
  const BookPage({required this.imageUrl, this.text, this.textPosition});

  final String imageUrl;
  final LocalizedText? text;
  final BookTextPosition? textPosition;
}

class Book {
  const Book({
    required this.bookId,
    required this.title,
    required this.description,
    required this.authorName,
    required this.coverUrl,
    required this.ageGroup,
    required this.pageCount,
    required this.likeCount,
    required this.viewCount,
    required this.status,
    required this.pages,
    required this.createdAt,
    required this.updatedAt,
  });

  final String bookId;
  final LocalizedText title;
  final LocalizedText description;
  final String authorName;
  final String coverUrl;
  final BookAgeGroup ageGroup;
  final int pageCount;
  final int likeCount;
  final int viewCount;
  final BookStatus status;
  final List<BookPage> pages;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get titleJa => title.preferred();

  String get descriptionJa => description.preferred();
}
