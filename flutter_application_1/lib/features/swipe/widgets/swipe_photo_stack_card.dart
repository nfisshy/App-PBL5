import 'package:flutter/material.dart';

import '../models/swipe_photo_item.dart';

/// Thẻ ảnh trong stack; [horizontalOffsetPercentage] từ [CardSwiper] (âm = trái, dương = phải).
class SwipePhotoStackCard extends StatelessWidget {
  const SwipePhotoStackCard({
    super.key,
    required this.photo,
    required this.horizontalOffsetPercentage,
    required this.verticalOffsetPercentage,
  });

  final SwipePhotoItem photo;
  final int horizontalOffsetPercentage;
  final int verticalOffsetPercentage;

  static const _radius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    final del = horizontalOffsetPercentage < 0
        ? ((-horizontalOffsetPercentage) / 90.0).clamp(0.0, 1.0)
        : 0.0;
    final kep = horizontalOffsetPercentage > 0
        ? (horizontalOffsetPercentage / 90.0).clamp(0.0, 1.0)
        : 0.0;

    return ClipRRect(
      borderRadius: _radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _image(),
          if (del > 0.05)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.22 * del),
                ),
              ),
            ),
          if (kep > 0.05)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2 * kep),
                ),
              ),
            ),
          if (del > 0.08)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Transform.rotate(
                  angle: -0.12,
                  child: Opacity(
                    opacity: del,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Text(
                        'DELETE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (kep > 0.08)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Transform.rotate(
                  angle: 0.12,
                  child: Opacity(
                    opacity: kep,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Text(
                        'KEEP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _image() {
    if (photo.thumbnailBytes != null) {
      return Image.memory(
        photo.thumbnailBytes!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }
    return Image.network(
      photo.previewUrl,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(
          color: Colors.grey.shade900,
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        (progress.expectedTotalBytes ?? 1)
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, _) => ColoredBox(
        color: Colors.grey.shade800,
        child: const Icon(Icons.broken_image_outlined, size: 64),
      ),
    );
  }
}
