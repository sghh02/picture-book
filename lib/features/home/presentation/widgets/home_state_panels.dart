import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeErrorPanel extends StatelessWidget {
  const HomeErrorPanel({super.key, required this.onRetry, this.buttonKey});

  final VoidCallback onRetry;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'えほんを よみこめませんでした',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            const Text('ネットワークやデータの状態を確認して、もういちど試してください。'),
            const Gap(16),
            FilledButton(
              key: buttonKey,
              onPressed: onRetry,
              child: const Text('リトライ'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeEmptyPanel extends StatelessWidget {
  const HomeEmptyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'この ねんれいの えほんは まだ ありません',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            const Text('べつの ねんれいフィルターも ためしてみよう。'),
          ],
        ),
      ),
    );
  }
}
