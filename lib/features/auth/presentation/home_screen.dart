import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photomanager/app/router/app_routes.dart';
import 'package:photomanager/features/auth/presentation/auth_controller.dart';
import 'package:photomanager/features/audio/domain/audio_capture_session.dart';
import 'package:photomanager/features/audio/domain/audio_capture_state.dart';
import 'package:photomanager/features/audio/domain/audio_statistics.dart';
import 'package:photomanager/features/audio/presentation/audio_providers.dart';
import 'package:photomanager/features/audio/presentation/widgets/audio_status_badge.dart';
import 'package:photomanager/features/call/domain/call_participant.dart';
import 'package:photomanager/features/call/presentation/signaling/call_signaling_providers.dart';
import 'package:photomanager/features/media/domain/audio_stream_state.dart';
import 'package:photomanager/features/media/domain/camera_state.dart';
import 'package:photomanager/features/media/domain/microphone_state.dart';
import 'package:photomanager/features/media/domain/video_stream_state.dart';
import 'package:photomanager/features/media/presentation/media_providers.dart';
import 'package:photomanager/features/media/presentation/widgets/media_status_badge.dart';
import 'package:photomanager/features/realtime/domain/connection_status.dart';
import 'package:photomanager/features/realtime/presentation/realtime_providers.dart';
import 'package:photomanager/features/realtime/presentation/widgets/connection_status_badge.dart';
import 'package:photomanager/features/speech_output/domain/speech_message.dart';
import 'package:photomanager/features/speech_output/domain/speech_queue_item.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';
import 'package:photomanager/features/speech_output/domain/speech_statistics.dart';
import 'package:photomanager/features/speech_output/presentation/speech_output_providers.dart';
import 'package:photomanager/features/speech_output/presentation/widgets/speech_status_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final realtimeStatus = ref.watch(connectionStatusProvider).valueOrNull ??
        ConnectionStatus.disconnected;
    final cameraState =
        ref.watch(cameraStateProvider).valueOrNull ?? const CameraState.idle();
    final microphoneState = ref.watch(microphoneStateProvider).valueOrNull ??
        const MicrophoneState.idle();
    final videoState = ref.watch(videoStreamStateProvider).valueOrNull ??
        const VideoStreamState.idle();
    final audioState = ref.watch(audioStreamStateProvider).valueOrNull ??
        const AudioStreamState.idle();
    final captureState = ref.watch(audioCaptureStateProvider).valueOrNull ??
        AudioCaptureState.idle;
    final captureStatistics = ref.watch(audioStatisticsProvider).valueOrNull ??
        const AudioStatistics.empty();
    final captureSession = ref.watch(currentAudioSessionProvider);
    final speechState =
        ref.watch(speechStateProvider).valueOrNull ?? SpeechState.idle;
    final speechStatistics = ref.watch(speechStatisticsProvider).valueOrNull ??
        const SpeechStatistics.empty();
    final latestSpeechMessage = ref.watch(speechMessageProvider).valueOrNull;
    final speechQueue =
        ref.watch(speechQueueProvider).valueOrNull ?? const <SpeechQueueItem>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Text(
                  'Welcome',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.username ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                _RealtimeStatusCard(status: realtimeStatus),
                const SizedBox(height: 12),
                _DevelopmentCallCard(
                  onSimulateIncoming: () async {
                    await ref
                        .read(currentCallSessionProvider.notifier)
                        .simulateIncomingCall(_developmentCaller);
                    if (context.mounted) {
                      context.push(AppRoutes.incomingCall);
                    }
                  },
                  onSimulateMissed: () async {
                    await ref
                        .read(currentCallSessionProvider.notifier)
                        .simulateMissedCall(_developmentCaller);
                  },
                ),
                const SizedBox(height: 32),
                _FeatureButton(
                  icon: Icons.contacts_outlined,
                  label: 'Contacts',
                  onPressed: () => context.push(AppRoutes.contacts),
                ),
                const SizedBox(height: 12),
                _FeatureButton(
                  icon: Icons.history_outlined,
                  label: 'Conversation History',
                  onPressed: () => context.push(AppRoutes.conversation),
                ),
                const SizedBox(height: 12),
                const _FeatureButton(
                  icon: Icons.person_outline,
                  label: 'Profile',
                ),
                const SizedBox(height: 12),
                _FeatureButton(
                  icon: Icons.api_outlined,
                  label: 'API Diagnostics',
                  onPressed: () => context.push(AppRoutes.apiDiagnostics),
                ),
                const SizedBox(height: 12),
                _MediaDiagnosticsCard(
                  cameraState: cameraState,
                  microphoneState: microphoneState,
                  videoState: videoState,
                  audioState: audioState,
                ),
                const SizedBox(height: 12),
                _AudioDiagnosticsCard(
                  state: captureState,
                  statistics: captureStatistics,
                  session: captureSession,
                ),
                const SizedBox(height: 12),
                _SpeechDiagnosticsCard(
                  state: speechState,
                  statistics: speechStatistics,
                  queueSize: speechQueue.length,
                  latestMessage: latestSpeechMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeechDiagnosticsCard extends StatelessWidget {
  const _SpeechDiagnosticsCard({
    required this.state,
    required this.statistics,
    required this.queueSize,
    required this.latestMessage,
  });

  final SpeechState state;
  final SpeechStatistics statistics;
  final int queueSize;
  final SpeechMessage? latestMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Speech Diagnostics',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                SpeechStatusBadge(state: state),
              ],
            ),
            const SizedBox(height: 10),
            Text('Queue Size: $queueSize'),
            Text('Spoken Count: ${statistics.spokenCount}'),
            Text(
              latestMessage == null
                  ? 'Latest Message: None'
                  : 'Latest Message: ${latestMessage!.text}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioDiagnosticsCard extends StatelessWidget {
  const _AudioDiagnosticsCard({
    required this.state,
    required this.statistics,
    required this.session,
  });

  final AudioCaptureState state;
  final AudioStatistics statistics;
  final AudioCaptureSession? session;

  @override
  Widget build(BuildContext context) {
    final currentSession = session;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Audio Diagnostics',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                AudioStatusBadge(state: state),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              currentSession == null
                  ? 'Current Session: None'
                  : 'Current Session: ${currentSession.sessionId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('Generated Chunks: ${statistics.chunkCount}'),
            Text('Recording Duration: ${statistics.totalDurationMs} ms'),
          ],
        ),
      ),
    );
  }
}

class _MediaDiagnosticsCard extends StatelessWidget {
  const _MediaDiagnosticsCard({
    required this.cameraState,
    required this.microphoneState,
    required this.videoState,
    required this.audioState,
  });

  final CameraState cameraState;
  final MicrophoneState microphoneState;
  final VideoStreamState videoState;
  final AudioStreamState audioState;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Media Diagnostics',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                MediaStatusBadge(
                  label: 'Camera',
                  state: cameraState.connectionState,
                ),
                MediaStatusBadge(
                  label: 'Microphone',
                  state: microphoneState.connectionState,
                ),
                MediaStatusBadge(
                  label: 'Video',
                  state: videoState.connectionState,
                ),
                MediaStatusBadge(
                  label: 'Audio',
                  state: audioState.connectionState,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const _developmentCaller = CallParticipant(
  username: 'dat001',
  displayName: 'DAT',
);

class _DevelopmentCallCard extends StatelessWidget {
  const _DevelopmentCallCard({
    required this.onSimulateIncoming,
    required this.onSimulateMissed,
  });

  final VoidCallback onSimulateIncoming;
  final VoidCallback onSimulateMissed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Call Signaling Test',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onSimulateIncoming,
              child: const Text('Simulate Incoming Call'),
            ),
            OutlinedButton(
              onPressed: onSimulateMissed,
              child: const Text('Simulate Missed Call'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealtimeStatusCard extends StatelessWidget {
  const _RealtimeStatusCard({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Text('Realtime Status'),
            ),
            ConnectionStatusBadge(status: status),
          ],
        ),
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  const _FeatureButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
