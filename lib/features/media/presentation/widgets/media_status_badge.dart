import 'package:flutter/material.dart';
import 'package:photomanager/features/media/domain/media_connection_state.dart';

class MediaStatusBadge extends StatelessWidget {
  const MediaStatusBadge({
    required this.label,
    required this.state,
    super.key,
  });

  final String label;
  final MediaConnectionState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      MediaConnectionState.ready => Colors.green,
      MediaConnectionState.streaming => Colors.blue,
      MediaConnectionState.initializing => Colors.orange,
      MediaConnectionState.paused => Colors.amber,
      MediaConnectionState.error => Colors.red,
      MediaConnectionState.idle || MediaConnectionState.stopped => Colors.grey,
    };

    return Chip(
      avatar: Icon(Icons.circle, size: 12, color: color),
      label: Text('$label: ${state.label}'),
      visualDensity: VisualDensity.compact,
    );
  }
}

extension MediaConnectionStateLabel on MediaConnectionState {
  String get label => switch (this) {
        MediaConnectionState.idle => 'Idle',
        MediaConnectionState.initializing => 'Initializing',
        MediaConnectionState.ready => 'Ready',
        MediaConnectionState.streaming => 'Streaming',
        MediaConnectionState.paused => 'Paused',
        MediaConnectionState.stopped => 'Stopped',
        MediaConnectionState.error => 'Error',
      };
}
