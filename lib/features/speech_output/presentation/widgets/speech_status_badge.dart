import 'package:flutter/material.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';

class SpeechStatusBadge extends StatelessWidget {
  const SpeechStatusBadge({
    required this.state,
    super.key,
  });

  final SpeechState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      SpeechState.ready => Colors.green,
      SpeechState.speaking => Colors.blue,
      SpeechState.initializing => Colors.orange,
      SpeechState.paused => Colors.amber,
      SpeechState.error => Colors.red,
      SpeechState.idle || SpeechState.stopped => Colors.grey,
    };

    return Chip(
      avatar: Icon(Icons.circle, size: 12, color: color),
      label: Text(state.label),
      visualDensity: VisualDensity.compact,
    );
  }
}

extension SpeechStateLabel on SpeechState {
  String get label => switch (this) {
        SpeechState.idle => 'Idle',
        SpeechState.initializing => 'Initializing',
        SpeechState.ready => 'Ready',
        SpeechState.speaking => 'Speaking',
        SpeechState.paused => 'Paused',
        SpeechState.stopped => 'Stopped',
        SpeechState.error => 'Error',
      };
}
