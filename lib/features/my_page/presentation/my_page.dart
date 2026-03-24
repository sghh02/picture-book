import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:picture_book/app/router.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  static const homeButtonKey = Key('my.homeButton');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    key: homeButtonKey,
                    onPressed: () => context.goNamed(AppRouteName.home),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('ホーム'),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'マイページ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Gap(88),
                ],
              ),
              const Gap(20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF0E6DC)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: _TabLabel(
                        label: 'りれき (0)',
                        selected: true,
                      ),
                    ),
                    Expanded(
                      child: _TabLabel(
                        label: 'いいね (0)',
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),
              const Expanded(
                child: _EmptyState(
                  title: 'まだ よんだ えほんが ありません。',
                  subtitle: 'ホームから えほんを えらんでみよう。',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected ? const Color(0xFFC4825A) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? const Color(0xFFC4825A) : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.history,
                size: 48,
                color: Color(0xFFC4825A),
              ),
              const Gap(16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
