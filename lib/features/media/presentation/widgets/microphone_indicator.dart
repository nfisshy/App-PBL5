import 'package:flutter/material.dart';
import 'package:photomanager/features/media/domain/microphone_state.dart';

class MicrophoneIndicator extends StatelessWidget {
  const MicrophoneIndicator({
    required this.state,
    super.key,
  });

  final MicrophoneState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(state.isMuted ? Icons.mic_off_outlined : Icons.mic_outlined),
        const SizedBox(width: 8),
        Text(state.isMuted ? 'Microphone Muted' : 'Microphone Active'),
      ],
    );
  }
}
