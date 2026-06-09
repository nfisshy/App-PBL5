import 'package:flutter/material.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_state.dart';

class AudioUploadStatusBadge extends StatelessWidget {
  const AudioUploadStatusBadge({
    required this.state,
    super.key,
  });

  final AudioUploadState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      AudioUploadState.completed => Colors.green,
      AudioUploadState.uploading => Colors.blue,
      AudioUploadState.preparing ||
      AudioUploadState.processing =>
        Colors.orange,
      AudioUploadState.failed => Colors.red,
      AudioUploadState.idle => Colors.grey,
    };

    return Chip(
      avatar: Icon(Icons.circle, size: 12, color: color),
      label: Text(state.label),
      visualDensity: VisualDensity.compact,
    );
  }
}

extension AudioUploadStateLabel on AudioUploadState {
  String get label => switch (this) {
        AudioUploadState.idle => 'Idle',
        AudioUploadState.preparing => 'Preparing',
        AudioUploadState.uploading => 'Uploading',
        AudioUploadState.processing => 'Processing',
        AudioUploadState.completed => 'Completed',
        AudioUploadState.failed => 'Failed',
      };
}
