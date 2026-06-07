import 'package:flutter/material.dart';
import 'package:photomanager/features/media/domain/camera_state.dart';

class CameraPreviewPlaceholder extends StatelessWidget {
  const CameraPreviewPlaceholder({
    required this.state,
    super.key,
  });

  final CameraState state;

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
              state.isEnabled
                  ? Icons.videocam_outlined
                  : Icons.videocam_off_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              state.isEnabled ? 'Camera Preview' : 'Camera Disabled',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(state.isFrontCamera ? 'Front Camera' : 'Rear Camera'),
          ],
        ),
      ),
    );
  }
}
