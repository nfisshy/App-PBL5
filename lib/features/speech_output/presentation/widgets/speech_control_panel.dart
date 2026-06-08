import 'package:flutter/material.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';

class SpeechControlPanel extends StatelessWidget {
  const SpeechControlPanel({
    required this.state,
    required this.onSpeakDraft,
    required this.onSpeakFinal,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    super.key,
  });

  final SpeechState state;
  final VoidCallback onSpeakDraft;
  final VoidCallback onSpeakFinal;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton(
          onPressed: onSpeakDraft,
          child: const Text('Speak Draft'),
        ),
        FilledButton(
          onPressed: onSpeakFinal,
          child: const Text('Speak Final'),
        ),
        OutlinedButton(
          onPressed: state == SpeechState.speaking ? onPause : null,
          child: const Text('Pause Speech'),
        ),
        OutlinedButton(
          onPressed: state == SpeechState.paused ? onResume : null,
          child: const Text('Resume Speech'),
        ),
        FilledButton.tonal(
          onPressed: state == SpeechState.speaking ||
                  state == SpeechState.paused ||
                  state == SpeechState.ready
              ? onStop
              : null,
          child: const Text('Stop Speech'),
        ),
      ],
    );
  }
}
