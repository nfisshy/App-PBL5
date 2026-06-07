import 'package:flutter/material.dart';

class VideoPlaceholder extends StatelessWidget {
  const VideoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Raspberry Video Stream',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
