import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_book/app/router.dart';
import 'package:picture_book/core/theme/app_theme.dart';

class PictureBookApp extends ConsumerWidget {
  const PictureBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'えほんのもり',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
