import 'package:flutter/material.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_state.dart';

class AudioUploadControlPanel extends StatelessWidget {
  const AudioUploadControlPanel({
    required this.state,
    required this.onUpload,
    required this.onCancel,
    required this.onGenerateResponse,
    super.key,
  });

  final AudioUploadState state;
  final VoidCallback onUpload;
  final VoidCallback onCancel;
  final VoidCallback onGenerateResponse;

  @override
  Widget build(BuildContext context) {
    final isActive = state == AudioUploadState.preparing ||
        state == AudioUploadState.uploading ||
        state == AudioUploadState.processing;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton(
          onPressed: isActive ? null : onUpload,
          child: const Text('Mock Upload Audio'),
        ),
        OutlinedButton(
          onPressed: isActive ? onCancel : null,
          child: const Text('Cancel Upload'),
        ),
        OutlinedButton(
          onPressed: isActive ? null : onGenerateResponse,
          child: const Text('Generate Mock Response'),
        ),
      ],
    );
  }
}
