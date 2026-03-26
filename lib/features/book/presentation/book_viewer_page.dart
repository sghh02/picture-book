import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:picture_book/app/router.dart';
import 'package:picture_book/features/book/domain/book.dart';
import 'package:picture_book/features/book/providers/book_viewer_providers.dart';
import 'package:picture_book/features/book/providers/books_providers.dart';

class BookViewerPage extends ConsumerStatefulWidget {
  const BookViewerPage({super.key, required this.bookId});

  static const backButtonKey = Key('viewer.backButton');
  static const homeButtonKey = Key('viewer.homeButton');
  static const overlayKey = Key('viewer.overlay');
  static const pageNumberKey = Key('viewer.pageNumber');
  static const likeButtonKey = Key('viewer.likeButton');
  static const endLikeButtonKey = Key('viewer.endLikeButton');
  static const surfaceKey = Key('viewer.surface');
  static const loadingKey = Key('viewer.loading');
  static const storyTextKey = Key('viewer.storyText');
  static const endScreenKey = Key('viewer.endScreen');

  final String bookId;

  @override
  ConsumerState<BookViewerPage> createState() => _BookViewerPageState();
}

class _BookViewerPageState extends ConsumerState<BookViewerPage> {
  static const _overlayHideDelay = Duration(seconds: 3);

  late final PageController _pageController;
  final Map<int, int> _retryNonces = <int, int>{};

  Timer? _overlayTimer;
  int _currentPage = 0;
  bool _isOverlayVisible = true;
  bool _didRecordOpen = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _showOverlay();
    });
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookByIdProvider(widget.bookId));
    final likedIdsAsync = ref.watch(likedBookIdsProvider);
    final isLiked =
        likedIdsAsync.asData?.value.contains(widget.bookId) ?? false;

    return bookAsync.when(
      loading: _buildLoading,
      error: (error, stackTrace) => _buildFailure(
        title: 'えほんを よみこめませんでした',
        message: 'もういちど ためしてみよう。',
        onRetry: () => ref.invalidate(booksProvider),
      ),
      data: (book) {
        if (book == null) {
          return _buildFailure(
            title: 'えほんが みつかりませんでした',
            message: 'ホームから べつの えほんを えらんでみよう。',
          );
        }

        _recordOpeningHistory(book);
        _precacheAdjacentPages(book, _currentPage);

        return _BookViewerScaffold(
          currentPage: _currentPage,
          totalPages: _totalPages(book),
          isOverlayVisible: _isOverlayVisible,
          isLiked: isLiked,
          onLikeToggle: () => _toggleLike(widget.bookId),
          onBackPressed: _goHome,
          onHomePressed: _goHome,
          onTapUp: (details, constraints) =>
              _handleTap(details, constraints, book),
          onNextPressed: () => _goToNextPage(book),
          onPreviousPressed: () => _goToPreviousPage(),
          pageController: _pageController,
          onPageChanged: (index) => _handlePageChanged(book, index),
          pageBuilder: (context, index) =>
              _buildPage(context, book, index, isLiked),
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(
        key: BookViewerPage.loadingKey,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildFailure({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(12),
                    Text(message, textAlign: TextAlign.center),
                    const Gap(24),
                    if (onRetry != null)
                      FilledButton(
                        onPressed: onRetry,
                        child: const Text('リトライ'),
                      ),
                    if (onRetry != null) const Gap(12),
                    FilledButton.tonal(
                      onPressed: _goHome,
                      child: const Text('ホームにもどる'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    Book book,
    int pageIndex,
    bool isLiked,
  ) {
    if (pageIndex == 0) {
      return _CoverPage(book: book);
    }

    if (pageIndex == _totalPages(book) - 1) {
      return _EndPage(
        book: book,
        isLiked: isLiked,
        onLikePressed: () => _toggleLike(book.bookId),
        onHomePressed: _goHome,
      );
    }

    final storyIndex = pageIndex - 1;
    final retryNonce = _retryNonces[pageIndex] ?? 0;

    return _StoryPage(
      key: ValueKey('viewer.story.$pageIndex.$retryNonce'),
      book: book,
      page: book.pages[storyIndex],
      pageIndex: storyIndex,
      onRetryImage: () {
        setState(() {
          _retryNonces[pageIndex] = retryNonce + 1;
        });
      },
    );
  }

  void _handleTap(TapUpDetails details, BoxConstraints constraints, Book book) {
    if (_currentPage == _totalPages(book) - 1) {
      return;
    }

    final xRatio = details.localPosition.dx / constraints.maxWidth;
    final yRatio = details.localPosition.dy / constraints.maxHeight;

    if (yRatio <= 0.12 || yRatio >= 0.88) {
      _toggleOverlay();
      return;
    }

    if (xRatio >= 0.6) {
      _goToNextPage(book);
      return;
    }

    if (xRatio <= 0.35) {
      _goToPreviousPage();
      return;
    }

    _toggleOverlay();
  }

  void _handlePageChanged(Book book, int index) {
    setState(() {
      _currentPage = index;
    });

    _showOverlay();
    _precacheAdjacentPages(book, index);
    _recordPageHistory(book, index);
  }

  void _goToNextPage(Book book) {
    final nextPage = _currentPage + 1;
    if (nextPage >= _totalPages(book)) {
      return;
    }

    unawaited(
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _goToPreviousPage() {
    if (_currentPage == 0) {
      return;
    }

    unawaited(
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _toggleOverlay() {
    if (_isOverlayVisible) {
      _overlayTimer?.cancel();
      setState(() {
        _isOverlayVisible = false;
      });
      return;
    }

    _showOverlay();
  }

  void _showOverlay() {
    _overlayTimer?.cancel();
    setState(() {
      _isOverlayVisible = true;
    });
    _overlayTimer = Timer(_overlayHideDelay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isOverlayVisible = false;
      });
    });
  }

  void _recordOpeningHistory(Book book) {
    if (_didRecordOpen) {
      return;
    }

    _didRecordOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(
        ref
            .read(bookViewerLocalStoreProvider)
            .recordHistory(
              bookId: book.bookId,
              lastPage: 0,
              readAt: DateTime.now(),
            ),
      );
    });
  }

  void _recordPageHistory(Book book, int viewerPage) {
    final lastPage = switch (viewerPage) {
      0 => 0,
      >= 1 when viewerPage <= book.pages.length => viewerPage,
      _ => book.pages.length,
    };

    unawaited(
      ref
          .read(bookViewerLocalStoreProvider)
          .recordHistory(
            bookId: book.bookId,
            lastPage: lastPage,
            readAt: DateTime.now(),
          ),
    );
  }

  Future<void> _toggleLike(String bookId) async {
    await ref.read(likedBookIdsProvider.notifier).toggleLike(bookId);
  }

  void _goHome() {
    _overlayTimer?.cancel();
    context.goNamed(AppRouteName.home);
  }

  void _precacheAdjacentPages(Book book, int currentPage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      for (final viewerPage in <int>{
        currentPage,
        currentPage - 1,
        currentPage + 1,
      }) {
        final imageUrl = _imageUrlForViewerPage(book, viewerPage);
        if (imageUrl == null || imageUrl.isEmpty) {
          continue;
        }

        unawaited(
          precacheImage(
            CachedNetworkImageProvider(imageUrl),
            context,
          ).catchError((_) => null),
        );
      }
    });
  }

  String? _imageUrlForViewerPage(Book book, int viewerPage) {
    if (viewerPage < 0 || viewerPage >= _totalPages(book)) {
      return null;
    }

    if (viewerPage == 0 || viewerPage == _totalPages(book) - 1) {
      return book.coverUrl;
    }

    return book.pages[viewerPage - 1].imageUrl;
  }

  int _totalPages(Book book) => book.pages.length + 2;
}

class _BookViewerScaffold extends StatelessWidget {
  const _BookViewerScaffold({
    required this.currentPage,
    required this.totalPages,
    required this.isOverlayVisible,
    required this.isLiked,
    required this.onLikeToggle,
    required this.onBackPressed,
    required this.onHomePressed,
    required this.onTapUp,
    required this.onNextPressed,
    required this.onPreviousPressed,
    required this.pageController,
    required this.onPageChanged,
    required this.pageBuilder,
  });

  final int currentPage;
  final int totalPages;
  final bool isOverlayVisible;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final VoidCallback onBackPressed;
  final VoidCallback onHomePressed;
  final void Function(TapUpDetails details, BoxConstraints constraints) onTapUp;
  final VoidCallback onNextPressed;
  final VoidCallback onPreviousPressed;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final IndexedWidgetBuilder pageBuilder;

  @override
  Widget build(BuildContext context) {
    final isEndScreen = currentPage == totalPages - 1;
    final canGoBack = currentPage > 0;
    final canGoForward = currentPage < totalPages - 1;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  key: BookViewerPage.surfaceKey,
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) => onTapUp(details, constraints),
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: onPageChanged,
                    itemCount: totalPages,
                    itemBuilder: pageBuilder,
                  ),
                ),
                if (!isEndScreen) ...[
                  AnimatedOpacity(
                    key: BookViewerPage.overlayKey,
                    opacity: isOverlayVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !isOverlayVisible,
                      child: _ViewerOverlayTopBar(
                        currentPage: currentPage,
                        totalPages: totalPages,
                        isLiked: isLiked,
                        onBackPressed: onBackPressed,
                        onLikePressed: onLikeToggle,
                      ),
                    ),
                  ),
                  if (isOverlayVisible) ...[
                    if (canGoBack)
                      _ViewerArrowButton(
                        alignment: Alignment.centerLeft,
                        icon: Icons.chevron_left_rounded,
                        onPressed: onPreviousPressed,
                      ),
                    if (canGoForward)
                      _ViewerArrowButton(
                        alignment: Alignment.centerRight,
                        icon: Icons.chevron_right_rounded,
                        onPressed: onNextPressed,
                      ),
                  ] else
                    _ViewerDotsIndicator(
                      currentPage: currentPage,
                      totalPages: totalPages,
                    ),
                ],
                if (isEndScreen)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: FilledButton.tonal(
                        key: BookViewerPage.homeButtonKey,
                        onPressed: onHomePressed,
                        child: const Text('ホームにもどる'),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ViewerOverlayTopBar extends StatelessWidget {
  const _ViewerOverlayTopBar({
    required this.currentPage,
    required this.totalPages,
    required this.isLiked,
    required this.onBackPressed,
    required this.onLikePressed,
  });

  final int currentPage;
  final int totalPages;
  final bool isLiked;
  final VoidCallback onBackPressed;
  final VoidCallback onLikePressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: [
            _CircularGlassButton(
              buttonKey: BookViewerPage.backButtonKey,
              icon: Icons.arrow_back_rounded,
              onPressed: onBackPressed,
            ),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  '${currentPage + 1} / $totalPages',
                  key: BookViewerPage.pageNumberKey,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Spacer(),
            _CircularGlassButton(
              buttonKey: BookViewerPage.likeButtonKey,
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              onPressed: onLikePressed,
              foregroundColor: isLiked ? const Color(0xFFF4C2C2) : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularGlassButton extends StatelessWidget {
  const _CircularGlassButton({
    required this.buttonKey,
    required this.icon,
    required this.onPressed,
    this.foregroundColor = Colors.white,
  });

  final Key buttonKey;
  final IconData icon;
  final VoidCallback onPressed;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: buttonKey,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.22),
        shape: const CircleBorder(),
        fixedSize: const Size(40, 40),
      ),
      icon: Icon(icon, color: foregroundColor),
    );
  }
}

class _ViewerArrowButton extends StatelessWidget {
  const _ViewerArrowButton({
    required this.alignment,
    required this.icon,
    required this.onPressed,
  });

  final Alignment alignment;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.58),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: const Color(0xFF4A3728), size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewerDotsIndicator extends StatelessWidget {
  const _ViewerDotsIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < totalPages; index++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: currentPage == index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.36),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoverPage extends StatelessWidget {
  const _CoverPage({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final isLandscapeTablet =
        MediaQuery.sizeOf(context).width >= 600 &&
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final illustrationSize = isLandscapeTablet
        ? 180.0
        : MediaQuery.sizeOf(context).width >= 600
        ? 200.0
        : 140.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: illustrationSize,
            height: illustrationSize * 1.18,
            child: _ViewerIllustration(
              book: book,
              imageUrl: book.coverUrl,
              title: book.titleJa,
              subtitle: 'cover',
            ),
          ),
          const Gap(24),
          Text(
            book.titleJa,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(12),
          Text(
            book.authorName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: const Color(0xFF8B7B6B)),
          ),
          const Gap(16),
          Text(
            book.descriptionJa,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
          ),
          const Gap(20),
          Wrap(
            spacing: 12,
            children: [
              _MetaChip(label: '${book.pageCount}ページ'),
              _MetaChip(label: book.ageGroup.label),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  const _StoryPage({
    super.key,
    required this.book,
    required this.page,
    required this.pageIndex,
    required this.onRetryImage,
  });

  final Book book;
  final BookPage page;
  final int pageIndex;
  final VoidCallback onRetryImage;

  @override
  Widget build(BuildContext context) {
    final isLandscapeTablet =
        MediaQuery.sizeOf(context).width >= 600 &&
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final text = page.text?.preferred();

    if (isLandscapeTablet) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 88, 24, 40),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: _StoryArtwork(
                book: book,
                page: page,
                pageIndex: pageIndex,
                onRetryImage: onRetryImage,
              ),
            ),
            const Gap(24),
            Expanded(
              flex: 5,
              child: _StoryTextCard(
                text: text,
                isCentered: page.textPosition == BookTextPosition.center,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _StoryArtwork(
          book: book,
          page: page,
          pageIndex: pageIndex,
          onRetryImage: onRetryImage,
        ),
        if (text != null)
          _StoryOverlayText(text: text, position: page.textPosition),
      ],
    );
  }
}

class _StoryArtwork extends StatelessWidget {
  const _StoryArtwork({
    required this.book,
    required this.page,
    required this.pageIndex,
    required this.onRetryImage,
  });

  final Book book;
  final BookPage page;
  final int pageIndex;
  final VoidCallback onRetryImage;

  @override
  Widget build(BuildContext context) {
    return _ViewerIllustration(
      book: book,
      imageUrl: page.imageUrl,
      title: book.titleJa,
      subtitle: '${pageIndex + 1}ページ',
      fit: BoxFit.cover,
      onRetryImage: onRetryImage,
      expand: true,
    );
  }
}

class _StoryOverlayText extends StatelessWidget {
  const _StoryOverlayText({required this.text, required this.position});

  final String text;
  final BookTextPosition? position;

  @override
  Widget build(BuildContext context) {
    final effectivePosition = position ?? BookTextPosition.bottom;
    final alignment = switch (effectivePosition) {
      BookTextPosition.top => Alignment.topCenter,
      BookTextPosition.bottom => Alignment.bottomCenter,
      BookTextPosition.center => Alignment.center,
    };
    final padding = switch (effectivePosition) {
      BookTextPosition.top => const EdgeInsets.fromLTRB(20, 92, 20, 20),
      BookTextPosition.bottom => const EdgeInsets.fromLTRB(20, 20, 20, 44),
      BookTextPosition.center => const EdgeInsets.all(20),
    };

    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(
              alpha: effectivePosition == BookTextPosition.center ? 0.22 : 0.44,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              text,
              key: BookViewerPage.storyTextKey,
              textAlign: effectivePosition == BookTextPosition.center
                  ? TextAlign.center
                  : TextAlign.start,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                height: 1.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryTextCard extends StatelessWidget {
  const _StoryTextCard({required this.text, required this.isCentered});

  final String? text;
  final bool isCentered;

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text!,
            key: BookViewerPage.storyTextKey,
            textAlign: isCentered ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              height: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EndPage extends StatelessWidget {
  const _EndPage({
    required this.book,
    required this.isLiked,
    required this.onLikePressed,
    required this.onHomePressed,
  });

  final Book book;
  final bool isLiked;
  final VoidCallback onLikePressed;
  final VoidCallback onHomePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              key: BookViewerPage.endScreenKey,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 120),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'おしまい',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(24),
                  SizedBox(
                    width: 120,
                    height: 142,
                    child: _ViewerIllustration(
                      book: book,
                      imageUrl: book.coverUrl,
                      title: book.titleJa,
                      subtitle: 'cover',
                    ),
                  ),
                  const Gap(20),
                  Text(
                    book.titleJa,
                    key: const Key('viewer.endTitle'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(8),
                  Text(book.authorName),
                  const Gap(28),
                  FilledButton.icon(
                    key: BookViewerPage.endLikeButtonKey,
                    onPressed: onLikePressed,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                    ),
                    label: Text(isLiked ? 'いいね済み' : 'いいねする'),
                  ),
                  const Gap(16),
                  TextButton(
                    onPressed: onHomePressed,
                    child: const Text('ホームにもどる'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ViewerIllustration extends StatelessWidget {
  const _ViewerIllustration({
    required this.book,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.fit = BoxFit.cover,
    this.onRetryImage,
    this.expand = false,
  });

  final Book book;
  final String imageUrl;
  final String title;
  final String subtitle;
  final BoxFit fit;
  final VoidCallback? onRetryImage;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = imageUrl.isEmpty
        ? _FallbackIllustration(book: book, title: title, subtitle: subtitle)
        : ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: fit,
              placeholder: (context, url) => const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFFFF5EE)),
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) =>
                  _ImageErrorPanel(onRetryImage: onRetryImage),
            ),
          );

    return expand ? SizedBox.expand(child: child) : child;
  }
}

class _FallbackIllustration extends StatelessWidget {
  const _FallbackIllustration({
    required this.book,
    required this.title,
    required this.subtitle,
  });

  final Book book;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final color = switch (book.ageGroup) {
      BookAgeGroup.age0To2 => const Color(0xFFFFE4CC),
      BookAgeGroup.age3To5 => const Color(0xFFD4E8D0),
      BookAgeGroup.age6Plus => const Color(0xFFDDD5F3),
    };
    final icon = switch (book.ageGroup) {
      BookAgeGroup.age0To2 => Icons.cloud_outlined,
      BookAgeGroup.age3To5 => Icons.forest_outlined,
      BookAgeGroup.age6Plus => Icons.auto_awesome_outlined,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxHeight <= 160 || constraints.maxWidth <= 128;

        if (isCompact) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [color, Color.lerp(color, Colors.white, 0.42)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(icon, size: 28, color: const Color(0xFFC4825A)),
            ),
          );
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [color, Color.lerp(color, Colors.white, 0.42)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 64, color: const Color(0xFFC4825A)),
                const Gap(16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A3728),
                  ),
                ),
                const Gap(8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B7B6B),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImageErrorPanel extends StatelessWidget {
  const _ImageErrorPanel({this.onRetryImage});

  final VoidCallback? onRetryImage;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E6),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: Color(0xFFC4825A),
              ),
              const Gap(12),
              const Text('画像を よみこめませんでした', textAlign: TextAlign.center),
              const Gap(12),
              if (onRetryImage != null)
                FilledButton.tonal(
                  key: const Key('viewer.retryImageButton'),
                  onPressed: onRetryImage,
                  child: const Text('リトライ'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6DC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
