import 'package:flutter/material.dart';
import 'package:photomanager/features/audio/domain/audio_capture_state.dart';

class RecordingControlPanel extends StatelessWidget {
  const RecordingControlPanel({
    required this.state,
    required this.onInitialize,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    super.key,
  });

  final AudioCaptureState state;
  final VoidCallback onInitialize;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: state == AudioCaptureState.initializing ||
                      state == AudioCaptureState.ready ||
                      state == AudioCaptureState.recording ||
                      state == AudioCaptureState.paused
                  ? null
                  : onInitialize,
              child: const Text('Initialize Audio'),
            ),
            FilledButton(
              onPressed: state == AudioCaptureState.ready ||
                      state == AudioCaptureState.stopped
                  ? onStart
                  : null,
              child: const Text('Start Recording'),
            ),
            OutlinedButton(
              onPressed: state == AudioCaptureState.recording ? onPause : null,
              child: const Text('Pause Recording'),
            ),
            OutlinedButton(
              onPressed: state == AudioCaptureState.paused ? onResume : null,
              child: const Text('Resume Recording'),
            ),
            FilledButton.tonal(
              onPressed: state == AudioCaptureState.recording ||
                      state == AudioCaptureState.paused
                  ? onStop
                  : null,
              child: const Text('Stop Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
