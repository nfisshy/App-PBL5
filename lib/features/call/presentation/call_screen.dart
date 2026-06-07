import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photomanager/features/call/domain/call_participant.dart';
import 'package:photomanager/features/call/domain/call_state.dart';
import 'package:photomanager/features/call/presentation/call_providers.dart';
import 'package:photomanager/features/call/presentation/widgets/call_control_button.dart';
import 'package:photomanager/features/call/presentation/widgets/conversation_message_list.dart';
import 'package:photomanager/features/call/presentation/widgets/video_placeholder.dart';
import 'package:photomanager/shared/widgets/app_loading_indicator.dart';

class CallScreen extends ConsumerWidget {
  const CallScreen({
    required this.username,
    super.key,
  });

  final String username;

  Future<void> _confirmEndCall(BuildContext context) async {
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

    if (shouldEndCall == true && context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callStateProvider(username));
    final participant = callState.valueOrNull?.participant;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          participant == null ? 'Call' : 'Call with ${participant.displayName}',
        ),
      ),
      body: SafeArea(
        child: callState.when(
          loading: () => const Center(child: AppLoadingIndicator()),
          error: (error, stackTrace) => _CallError(
            onRetry: () =>
                ref.read(callStateProvider(username).notifier).load(),
          ),
          data: (state) => state == null
              ? const Center(child: Text('Participant not found.'))
              : _CallContent(
                  state: state,
                  onToggleMic: () {
                    ref.read(callStateProvider(username).notifier).toggleMic();
                  },
                  onEndCall: () => _confirmEndCall(context),
                ),
        ),
      ),
    );
  }
}

class _CallContent extends StatelessWidget {
  const _CallContent({
    required this.state,
    required this.onToggleMic,
    required this.onEndCall,
  });

  final CallState state;
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
                  const VideoPlaceholder(),
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
