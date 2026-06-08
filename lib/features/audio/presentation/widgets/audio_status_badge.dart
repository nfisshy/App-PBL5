import 'package:flutter/material.dart';
import 'package:photomanager/features/audio/domain/audio_capture_state.dart';

class AudioStatusBadge extends StatelessWidget {
  const AudioStatusBadge({
    required this.state,
    super.key,
  });

  final AudioCaptureState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      AudioCaptureState.ready => Colors.green,
      AudioCaptureState.recording => Colors.red,
      AudioCaptureState.initializing => Colors.orange,
      AudioCaptureState.paused => Colors.amber,
      AudioCaptureState.error => Colors.red,
      AudioCaptureState.idle || AudioCaptureState.stopped => Colors.grey,
    };

    return Chip(
      avatar: Icon(Icons.circle, size: 12, color: color),
      label: Text(state.label),
      visualDensity: VisualDensity.compact,
    );
  }
}

extension AudioCaptureStateLabel on AudioCaptureState {
  String get label => switch (this) {
        AudioCaptureState.idle => 'Idle',
        AudioCaptureState.initializing => 'Initializing',
        AudioCaptureState.ready => 'Ready',
        AudioCaptureState.recording => 'Recording',
        AudioCaptureState.paused => 'Paused',
        AudioCaptureState.stopped => 'Stopped',
        AudioCaptureState.error => 'Error',
      };
}
