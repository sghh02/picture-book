import 'package:flutter/material.dart';
import 'package:picture_book/features/book/domain/book.dart';

class HomeBookCover extends StatelessWidget {
  const HomeBookCover({super.key, required this.book, required this.size});

  final Book book;
  final double size;

  static const _palette = <Color>[
    Color(0xFFFFE4CC),
    Color(0xFFD4E8D0),
    Color(0xFFF5DEB3),
    Color(0xFFCCE5F0),
    Color(0xFFDDD5F3),
    Color(0xFFE8D5B7),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _palette[book.bookId.hashCode.abs() % _palette.length];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.white, 0.4)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconFor(book.ageGroup),
              size: size * 0.34,
              color: const Color(0xFFC4825A),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                book.titleJa,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF4A3728),
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(BookAgeGroup ageGroup) {
    return switch (ageGroup) {
      BookAgeGroup.age0To2 => Icons.cloud_outlined,
      BookAgeGroup.age3To5 => Icons.forest_outlined,
      BookAgeGroup.age6Plus => Icons.auto_awesome_outlined,
    };
  }
}
