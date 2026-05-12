import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

import '../models/swipe_photo_item.dart';

Future<void> showSwipePhotoDetailSheet({
  required BuildContext context,
  required SwipePhotoItem photo,
  required CardSwiperController swiperController,
  required bool isFavorite,
  required bool isBookmarked,
  required VoidCallback onToggleFavorite,
  required VoidCallback onToggleBookmark,
}) {
  return showMaterialModalBottomSheet<void>(
    context: context,
    expand: false,
    bounce: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (ctx) {
      final dateStr = DateFormat.yMMMd().add_Hm().format(photo.createdAt);

      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Material(
                color: Colors.white.withValues(alpha: 0.78),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Thông tin',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        Icons.sd_storage_outlined,
                        'Kích thước',
                        photo.formattedSize(),
                      ),
                      _infoRow(
                        Icons.calendar_today_outlined,
                        'Tạo lúc',
                        dateStr,
                      ),
                      _infoRow(
                        Icons.aspect_ratio,
                        'Pixel',
                        '${photo.pixelWidth} × ${photo.pixelHeight}',
                      ),
                      const Divider(height: 32),
                      const Text(
                        'Thao tác nhanh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _QuickTile(
                        icon: Icons.auto_awesome,
                        label: 'Enhance with AI',
                        onTap: () {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Coming soon — Enhance with AI'),
                            ),
                          );
                        },
                      ),
                      _QuickTile(
                        icon: isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        label: 'Add to bookmark',
                        tint: Colors.amber.shade800,
                        onTap: onToggleBookmark,
                      ),
                      _QuickTile(
                        icon: isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        label: 'Add to favourite',
                        tint: Colors.pinkAccent,
                        onTap: onToggleFavorite,
                      ),
                      _QuickTile(
                        icon: Icons.photo_album_outlined,
                        label: 'Add to album',
                        onTap: () {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Coming soon — chọn album'),
                            ),
                          );
                        },
                      ),
                      _QuickTile(
                        icon: Icons.ios_share_rounded,
                        label: 'Share',
                        onTap: () async {
                          await SharePlus.instance.share(
                            ShareParams(
                              text: photo.previewUrl,
                              subject: photo.title ?? 'Photo',
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Future.microtask(
                                  () => swiperController.swipe(
                                    CardSwiperDirection.left,
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              child: const Text('Delete'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Future.microtask(
                                  () => swiperController.swipe(
                                    CardSwiperDirection.right,
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green.shade800,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              child: const Text('Keep'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _infoRow(IconData icon, String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: tint ?? Colors.deepPurple, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
