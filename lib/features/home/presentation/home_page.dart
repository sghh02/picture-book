import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:picture_book/app/router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const profileButtonKey = Key('home.profileButton');
  static const sampleBookCardKey = Key('home.sampleBookCard');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Row(
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
            const Gap(24),
            const _SectionTitle(title: 'ねんれいフィルター'),
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _FilterChip(label: 'すべて', selected: true),
                _FilterChip(label: '0〜2さい'),
                _FilterChip(label: '3〜5さい'),
                _FilterChip(label: '6さい〜'),
              ],
            ),
            const Gap(28),
            const _SectionTitle(title: 'おすすめ'),
            const Gap(12),
            GestureDetector(
              key: sampleBookCardKey,
              onTap: () => context.pushNamed(
                AppRouteName.bookViewer,
                pathParameters: {'bookId': 'sample-book'},
              ),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: 176,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFF0E6), Color(0xFFFFF9F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.auto_stories_outlined,
                            size: 52,
                            color: Color(0xFFC4825A),
                          ),
                        ),
                      ),
                      Text(
                        'サンプルえほん',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Gap(4),
                      Text('ビューアルートの動作確認用カード'),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(28),
            const _SectionTitle(title: 'にんきランキング'),
            const Gap(12),
            const _PlaceholderPanel(
              title: 'ランキングは次のステップで接続します',
              subtitle: 'Firestore と状態管理を入れる前のプレースホルダーです。',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
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
    );
  }
}

class _PlaceholderPanel extends StatelessWidget {
  const _PlaceholderPanel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Gap(8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
