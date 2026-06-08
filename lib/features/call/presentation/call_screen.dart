import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photomanager/core/services/speech/speech_output_service.dart';
import 'package:photomanager/features/audio/domain/audio_capture_session.dart';
import 'package:photomanager/features/audio/domain/audio_capture_state.dart';
import 'package:photomanager/features/audio/domain/audio_chunk.dart';
import 'package:photomanager/features/audio/domain/audio_statistics.dart';
import 'package:photomanager/features/audio/presentation/audio_providers.dart';
import 'package:photomanager/features/audio/presentation/widgets/audio_chunk_list.dart';
import 'package:photomanager/features/audio/presentation/widgets/audio_statistics_card.dart';
import 'package:photomanager/features/audio/presentation/widgets/audio_status_badge.dart';
import 'package:photomanager/features/audio/presentation/widgets/recording_control_panel.dart';
import 'package:photomanager/features/call/domain/call_participant.dart';
import 'package:photomanager/features/call/domain/call_state.dart';
import 'package:photomanager/features/call/domain/signaling/call_status.dart';
import 'package:photomanager/features/call/presentation/call_providers.dart';
import 'package:photomanager/features/call/presentation/signaling/call_signaling_providers.dart';
import 'package:photomanager/features/call/presentation/widgets/call_control_button.dart';
import 'package:photomanager/features/call/presentation/widgets/call_status_banner.dart';
import 'package:photomanager/features/call/presentation/widgets/conversation_message_list.dart';
import 'package:photomanager/features/conversation/presentation/conversation_providers.dart';
import 'package:photomanager/features/media/domain/audio_stream_state.dart';
import 'package:photomanager/features/media/domain/camera_state.dart';
import 'package:photomanager/features/media/domain/microphone_state.dart';
import 'package:photomanager/features/media/domain/video_stream_state.dart';
import 'package:photomanager/features/media/presentation/media_providers.dart';
import 'package:photomanager/features/media/presentation/widgets/camera_preview_placeholder.dart';
import 'package:photomanager/features/media/presentation/widgets/media_status_badge.dart';
import 'package:photomanager/features/media/presentation/widgets/microphone_indicator.dart';
import 'package:photomanager/features/media/presentation/widgets/stream_statistics_card.dart';
import 'package:photomanager/features/realtime/domain/connection_status.dart';
import 'package:photomanager/features/realtime/presentation/realtime_providers.dart';
import 'package:photomanager/features/realtime/presentation/widgets/connection_status_badge.dart';
import 'package:photomanager/features/speech_output/domain/speech_message.dart';
import 'package:photomanager/features/speech_output/domain/speech_queue_item.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';
import 'package:photomanager/features/speech_output/domain/speech_statistics.dart';
import 'package:photomanager/features/speech_output/presentation/speech_output_providers.dart';
import 'package:photomanager/features/speech_output/presentation/widgets/speech_control_panel.dart';
import 'package:photomanager/features/speech_output/presentation/widgets/speech_message_card.dart';
import 'package:photomanager/features/speech_output/presentation/widgets/speech_queue_card.dart';
import 'package:photomanager/features/speech_output/presentation/widgets/speech_status_badge.dart';
import 'package:photomanager/shared/widgets/app_loading_indicator.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({
    required this.username,
    super.key,
  });

  final String username;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  bool _signalingStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(mediaActionsProvider).initialize());
      }
    });
  }

  @override
  void dispose() {
    unawaited(ref.read(mediaActionsProvider).dispose());
    unawaited(
      ref.read(currentAudioSessionProvider.notifier).disposeCapture(),
    );
    super.dispose();
  }

  Future<void> _confirmEndCall() async {
    final shouldEndCall = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End call?'),
        content: const Text('Are you sure you want to end this call?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('End Call'),
          ),
        ],
      ),
    );

    if (shouldEndCall == true && mounted) {
      await ref.read(currentCallSessionProvider.notifier).endCall();
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callStateProvider(widget.username));
    final participant = callState.valueOrNull?.participant;
    final signalingStatus =
        ref.watch(callStatusProvider).valueOrNull ?? CallStatus.idle;
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
    final audioCaptureState =
        ref.watch(audioCaptureStateProvider).valueOrNull ??
            AudioCaptureState.idle;
    final audioStatistics = ref.watch(audioStatisticsProvider).valueOrNull ??
        const AudioStatistics.empty();
    final audioSession = ref.watch(currentAudioSessionProvider);
    final audioChunks = ref.watch(recentAudioChunksProvider);
    final speechState =
        ref.watch(speechStateProvider).valueOrNull ?? SpeechState.idle;
    final speechStatistics = ref.watch(speechStatisticsProvider).valueOrNull ??
        const SpeechStatistics.empty();
    final spokenMessage = ref.watch(speechMessageProvider).valueOrNull;
    final speechQueue =
        ref.watch(speechQueueProvider).valueOrNull ?? const <SpeechQueueItem>[];

    if (participant != null) {
      _startSignaling(participant);
      ref.watch(
        seedCallConversationProvider(
          ConversationSeedRequest(
            participantUsername: participant.username,
            participantDisplayName: participant.displayName,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          participant == null ? 'Call' : 'Call with ${participant.displayName}',
        ),
        actions: [
          Center(child: ConnectionStatusBadge(status: realtimeStatus)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: callState.when(
          loading: () => const Center(child: AppLoadingIndicator()),
          error: (error, stackTrace) => _CallError(
            onRetry: () =>
                ref.read(callStateProvider(widget.username).notifier).load(),
          ),
          data: (state) => state == null
              ? const Center(child: Text('Participant not found.'))
              : _CallContent(
                  state: state,
                  signalingStatus: signalingStatus,
                  cameraState: cameraState,
                  microphoneState: microphoneState,
                  videoState: videoState,
                  audioState: audioState,
                  mediaActions: ref.read(mediaActionsProvider),
                  audioCaptureState: audioCaptureState,
                  audioStatistics: audioStatistics,
                  audioSession: audioSession,
                  audioChunks: audioChunks,
                  audioController:
                      ref.read(currentAudioSessionProvider.notifier),
                  speechState: speechState,
                  speechStatistics: speechStatistics,
                  spokenMessage: spokenMessage,
                  speechQueue: speechQueue,
                  speechActions: ref.read(speechOutputServiceProvider),
                  onToggleMic: () {
                    ref
                        .read(callStateProvider(widget.username).notifier)
                        .toggleMic();
                  },
                  onEndCall: _confirmEndCall,
                ),
        ),
      ),
    );
  }

  void _startSignaling(CallParticipant participant) {
    if (_signalingStarted) {
      return;
    }

    _signalingStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(currentCallSessionProvider.notifier)
            .startOutgoingCall(participant);
      }
    });
  }
}

class _CallContent extends StatelessWidget {
  const _CallContent({
    required this.state,
    required this.signalingStatus,
    required this.cameraState,
    required this.microphoneState,
    required this.videoState,
    required this.audioState,
    required this.mediaActions,
    required this.audioCaptureState,
    required this.audioStatistics,
    required this.audioSession,
    required this.audioChunks,
    required this.audioController,
    required this.speechState,
    required this.speechStatistics,
    required this.spokenMessage,
    required this.speechQueue,
    required this.speechActions,
    required this.onToggleMic,
    required this.onEndCall,
  });

  final CallState state;
  final CallStatus signalingStatus;
  final CameraState cameraState;
  final MicrophoneState microphoneState;
  final VideoStreamState videoState;
  final AudioStreamState audioState;
  final MediaActions mediaActions;
  final AudioCaptureState audioCaptureState;
  final AudioStatistics audioStatistics;
  final AudioCaptureSession? audioSession;
  final List<AudioChunk> audioChunks;
  final AudioCaptureSessionController audioController;
  final SpeechState speechState;
  final SpeechStatistics speechStatistics;
  final SpeechMessage? spokenMessage;
  final List<SpeechQueueItem> speechQueue;
  final SpeechOutputService speechActions;
  final VoidCallback onToggleMic;
  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CallStatusBanner(status: signalingStatus),
                  const SizedBox(height: 16),
                  CameraPreviewPlaceholder(state: cameraState),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                  const SizedBox(height: 12),
                  MicrophoneIndicator(state: microphoneState),
                  const SizedBox(height: 12),
                  StreamStatisticsCard(
                    videoState: videoState,
                    audioState: audioState,
                  ),
                  const SizedBox(height: 12),
                  _MediaControls(
                    cameraState: cameraState,
                    microphoneState: microphoneState,
                    videoState: videoState,
                    audioState: audioState,
                    actions: mediaActions,
                  ),
                  const SizedBox(height: 16),
                  _AudioCaptureSection(
                    state: audioCaptureState,
                    statistics: audioStatistics,
                    session: audioSession,
                    chunks: audioChunks,
                    controller: audioController,
                  ),
                  const SizedBox(height: 16),
                  _SpeechOutputSection(
                    state: speechState,
                    statistics: speechStatistics,
                    spokenMessage: spokenMessage,
                    queue: speechQueue,
                    actions: speechActions,
                  ),
                  const SizedBox(height: 16),
                  _ParticipantCard(participant: state.participant),
                  const SizedBox(height: 24),
                  Text(
                    'Conversation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ConversationMessageList(messages: state.messages),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CallControlButton(
                      icon: state.isMicEnabled ? Icons.mic : Icons.mic_off,
                      label: state.isMicEnabled ? 'Mic ON' : 'Mic OFF',
                      isActive: state.isMicEnabled,
                      onPressed: onToggleMic,
                    ),
                    CallControlButton(
                      icon: Icons.call_end,
                      label: 'End Call',
                      isDestructive: true,
                      onPressed: onEndCall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeechOutputSection extends StatelessWidget {
  const _SpeechOutputSection({
    required this.state,
    required this.statistics,
    required this.spokenMessage,
    required this.queue,
    required this.actions,
  });

  final SpeechState state;
  final SpeechStatistics statistics;
  final SpeechMessage? spokenMessage;
  final List<SpeechQueueItem> queue;
  final SpeechOutputService actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Speech Output',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                SpeechStatusBadge(state: state),
              ],
            ),
            const SizedBox(height: 8),
            Text('Queued Messages: ${statistics.queuedCount}'),
            Text('Spoken Messages: ${statistics.spokenCount}'),
            Text('Speaking: ${statistics.isSpeaking ? 'Yes' : 'No'}'),
            const SizedBox(height: 8),
            SpeechMessageCard(message: spokenMessage),
            SpeechQueueCard(items: queue),
            const SizedBox(height: 8),
            SpeechControlPanel(
              state: state,
              onSpeakDraft: () => actions.speakDraft(
                'Xin chao, day la ban nhap.',
              ),
              onSpeakFinal: () => actions.speakFinal(
                'Xin chao, day la ket qua cuoi cung.',
              ),
              onPause: actions.pause,
              onResume: actions.resume,
              onStop: actions.stop,
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioCaptureSection extends StatelessWidget {
  const _AudioCaptureSection({
    required this.state,
    required this.statistics,
    required this.session,
    required this.chunks,
    required this.controller,
  });

  final AudioCaptureState state;
  final AudioStatistics statistics;
  final AudioCaptureSession? session;
  final List<AudioChunk> chunks;
  final AudioCaptureSessionController controller;

  @override
  Widget build(BuildContext context) {
    final currentSession = session;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Audio Capture',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                AudioStatusBadge(state: state),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              currentSession == null
                  ? 'No active audio session'
                  : 'Session: ${currentSession.sessionId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            AudioStatisticsCard(statistics: statistics),
            const SizedBox(height: 12),
            RecordingControlPanel(
              state: state,
              onInitialize: controller.initialize,
              onStart: controller.startRecording,
              onPause: controller.pauseRecording,
              onResume: controller.resumeRecording,
              onStop: controller.stopRecording,
            ),
            const SizedBox(height: 16),
            Text(
              'Latest Audio Chunks',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            AudioChunkList(chunks: chunks),
          ],
        ),
      ),
    );
  }
}

class _MediaControls extends StatelessWidget {
  const _MediaControls({
    required this.cameraState,
    required this.microphoneState,
    required this.videoState,
    required this.audioState,
    required this.actions,
  });

  final CameraState cameraState;
  final MicrophoneState microphoneState;
  final VideoStreamState videoState;
  final AudioStreamState audioState;
  final MediaActions actions;

  @override
  Widget build(BuildContext context) {
    final isStreaming = videoState.isStreaming || audioState.isStreaming;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: cameraState.isEnabled ? null : actions.enableCamera,
              child: const Text('Enable Camera'),
            ),
            OutlinedButton(
              onPressed: cameraState.isEnabled ? actions.disableCamera : null,
              child: const Text('Disable Camera'),
            ),
            OutlinedButton(
              onPressed: actions.switchCamera,
              child: const Text('Switch Camera'),
            ),
            OutlinedButton(
              onPressed:
                  microphoneState.isMuted ? null : actions.muteMicrophone,
              child: const Text('Mute Microphone'),
            ),
            OutlinedButton(
              onPressed:
                  microphoneState.isMuted ? actions.unmuteMicrophone : null,
              child: const Text('Unmute Microphone'),
            ),
            FilledButton(
              onPressed: isStreaming ? null : actions.startStreams,
              child: const Text('Start Stream'),
            ),
            FilledButton.tonal(
              onPressed: isStreaming ? actions.stopStreams : null,
              child: const Text('Stop Stream'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({required this.participant});

  final CallParticipant participant;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(participant.displayName.characters.first),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('@${participant.username}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallError extends StatelessWidget {
  const _CallError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Unable to prepare the call.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
