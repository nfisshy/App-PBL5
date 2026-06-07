import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photomanager/app/router/app_routes.dart';
import 'package:photomanager/features/conversation/domain/conversation_history.dart';
import 'package:photomanager/features/conversation/presentation/conversation_providers.dart';
import 'package:photomanager/shared/widgets/app_loading_indicator.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(conversationHistoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Conversation History')),
      body: SafeArea(
        child: histories.when(
          loading: () => const Center(child: AppLoadingIndicator()),
          error: (error, stackTrace) => _RefreshableMessage(
            message: 'Unable to load conversation history.',
            onRefresh: () =>
                ref.read(conversationHistoryListProvider.notifier).load(),
          ),
          data: (items) => items.isEmpty
              ? _RefreshableMessage(
                  message: 'No conversation history yet.',
                  onRefresh: () =>
                      ref.read(conversationHistoryListProvider.notifier).load(),
                )
              : _HistoryList(
                  histories: items,
                  onRefresh: () =>
                      ref.read(conversationHistoryListProvider.notifier).load(),
                ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.histories,
    required this.onRefresh,
  });

  final List<ConversationHistory> histories;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: histories.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final history = histories[index];
          return ListTile(
            onTap: () => context.push(
              AppRoutes.conversationDetail(history.conversationId),
            ),
            leading: CircleAvatar(
              child: Text(history.participantDisplayName.characters.first),
            ),
            title: Text(history.participantDisplayName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@${history.participantUsername}'),
                Text(
                  history.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Text(
              _formatTimestamp(history.lastMessageAt),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          );
        },
      ),
    );
  }
}

class _RefreshableMessage extends StatelessWidget {
  const _RefreshableMessage({
    required this.message,
    required this.onRefresh,
  });

  final String message;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Center(child: Text(message)),
          ),
        ],
      ),
    );
  }
}

String _formatTimestamp(DateTime timestamp) {
  final local = timestamp.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month} $hour:$minute';
}
