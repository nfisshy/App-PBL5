import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/photos/photo_library_permission.dart';
import '../../shared/shared.dart';
import 'data/mock_swipe_photos.dart';
import 'models/swipe_photo_item.dart';
import 'widgets/photo_detail_bottom_sheet.dart';
import 'widgets/swipe_photo_stack_card.dart';

/// Vuốt trái: xóa · Vuốt phải: giữ. Animation theo tay qua [CardSwiper].
/// Góp ý khác có thể xem `appinio_swiper` hoặc [PageView] + gesture tùy biến —
/// hiện tại giữ **flutter_card_swiper** như đã thống nhất.
class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key, this.photos});

  /// Override mock bằng danh sách thật từ [PhotoManager] sau.
  final List<SwipePhotoItem>? photos;

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  late final List<SwipePhotoItem> _deck;
  final CardSwiperController _swiperController = CardSwiperController();
  final Set<String> _favorites = {};
  final Set<String> _bookmarks = {};

  /// Index ảnh đang hiển thị (đầu chồng).
  int _focusIndex = 0;
  bool _sessionDone = false;

  @override
  void initState() {
    super.initState();
    _deck = List<SwipePhotoItem>.from(widget.photos ?? kMockSwipePhotos);
    unawaited(requestPhotoLibraryAccess());
  }

  @override
  void dispose() {
    unawaited(_swiperController.dispose());
    super.dispose();
  }

  SwipePhotoItem? get _current {
    if (_sessionDone || _deck.isEmpty) return null;
    final i = _focusIndex.clamp(0, _deck.length - 1);
    return _deck[i];
  }

  Future<void> _sharePhoto(SwipePhotoItem p) async {
    await SharePlus.instance.share(
      ShareParams(text: p.previewUrl, subject: p.title ?? 'Photo'),
    );
  }

  void _toggleFavorite(SwipePhotoItem? p) {
    if (p == null) return;
    setState(() {
      if (_favorites.contains(p.id)) {
        _favorites.remove(p.id);
      } else {
        _favorites.add(p.id);
      }
    });
  }

  void _toggleBookmark(SwipePhotoItem? p) {
    if (p == null) return;
    setState(() {
      if (_bookmarks.contains(p.id)) {
        _bookmarks.remove(p.id);
      } else {
        _bookmarks.add(p.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    // CardSwiper: [threshold] chỉ được trong 1..100 (theo package), dùng như ngưỡng pixel vuốt.
    final w = MediaQuery.sizeOf(context).width;
    final thresholdPx = (w * 0.22).round().clamp(36, 100);

    if (_deck.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              const Center(
                child: Text(
                  'Không có ảnh để swipe',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              Positioned(
                left: 4,
                top: topPad + 4,
                child: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_sessionDone) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white70,
                      size: 56,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đã duyệt hết ảnh trong batch này',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 4,
                top: topPad + 4,
                child: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final p = _current;

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SwipeTopBar(
              topPad: 0,
              agoLabel: p != null
                  ? timeago.format(p.createdAt, locale: 'en')
                  : '—',
              onBack: () => Navigator.maybePop(context),
              canUndo: _focusIndex > 0,
              onUndo: () => _swiperController.undo(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, bc) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CardSwiper(
                          key: ValueKey(_deck.length),
                          controller: _swiperController,
                          cardsCount: _deck.length,
                          numberOfCardsDisplayed: 2,
                          isLoop: false,
                          padding: const EdgeInsets.fromLTRB(14, 8, 64, 24),
                          scale: 0.92,
                          maxAngle: 22,
                          threshold: thresholdPx,
                          allowedSwipeDirection:
                              const AllowedSwipeDirection.only(
                                left: true,
                                right: true,
                              ),
                          onSwipe: (prev, curr, direction) async {
                            if (curr != null && mounted) {
                              setState(() => _focusIndex = curr);
                            }
                            if (!context.mounted) return true;
                            if (direction == CardSwiperDirection.right) {
                              await StreakScope.of(context).increment();
                            }
                            return true;
                          },
                          onUndo: (_, restoredToIndex, _) {
                            if (mounted) {
                              setState(() => _focusIndex = restoredToIndex);
                            }
                            return true;
                          },
                          onEnd: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              setState(() => _sessionDone = true);
                            });
                          },
                          cardBuilder: (context, index, hp, vp) {
                            final item = _deck[index];
                            return SwipePhotoStackCard(
                              photo: item,
                              horizontalOffsetPercentage: hp,
                              verticalOffsetPercentage: vp,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: bc.maxHeight * 0.06,
                        bottom: bc.maxHeight * 0.18,
                        child: _SwipeActionRail(
                          isFavorite: p != null && _favorites.contains(p.id),
                          isBookmarked: p != null && _bookmarks.contains(p.id),
                          onFavorite: () => _toggleFavorite(p),
                          onBookmark: () => _toggleBookmark(p),
                          onShare: () async {
                            if (p != null) await _sharePhoto(p);
                          },
                          onInfo: () async {
                            if (p == null) return;
                            await showSwipePhotoDetailSheet(
                              context: context,
                              photo: p,
                              swiperController: _swiperController,
                              isFavorite: _favorites.contains(p.id),
                              isBookmarked: _bookmarks.contains(p.id),
                              onToggleFavorite: () => _toggleFavorite(p),
                              onToggleBookmark: () => _toggleBookmark(p),
                            );
                            if (mounted) setState(() {});
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeTopBar extends StatelessWidget {
  const _SwipeTopBar({
    required this.topPad,
    required this.agoLabel,
    required this.onBack,
    required this.onUndo,
    required this.canUndo,
  });

  final double topPad;
  final String agoLabel;
  final VoidCallback onBack;
  final VoidCallback onUndo;
  final bool canUndo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, topPad + 4, 8, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Expanded(
            child: Text(
              agoLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: canUndo ? onUndo : null,
            icon: const Icon(Icons.undo_rounded, color: Colors.white),
            tooltip: 'Undo',
          ),
        ],
      ),
    );
  }
}

class _SwipeActionRail extends StatelessWidget {
  const _SwipeActionRail({
    required this.isFavorite,
    required this.isBookmarked,
    required this.onFavorite,
    required this.onBookmark,
    required this.onShare,
    required this.onInfo,
  });

  final bool isFavorite;
  final bool isBookmarked;
  final VoidCallback onFavorite;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    Widget bubble({required Widget child}) {
      return Material(
        color: Colors.black38,
        elevation: 0,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        bubble(
          child: IconButton(
            tooltip: 'Favourite',
            onPressed: onFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.pinkAccent : Colors.white,
            ),
          ),
        ),
        bubble(
          child: IconButton(
            tooltip: 'Bookmark',
            onPressed: onBookmark,
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.amber : Colors.white,
            ),
          ),
        ),
        bubble(
          child: IconButton(
            tooltip: 'Share',
            onPressed: onShare,
            icon: const Icon(Icons.share_rounded, color: Colors.white),
          ),
        ),
        bubble(
          child: IconButton(
            tooltip: 'Info',
            onPressed: onInfo,
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
