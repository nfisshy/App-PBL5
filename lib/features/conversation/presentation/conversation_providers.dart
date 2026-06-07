import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/core/storage/app_database.dart';
import 'package:photomanager/features/conversation/data/drift_conversation_repository.dart';
import 'package:photomanager/features/conversation/domain/clear_history_use_case.dart';
import 'package:photomanager/features/conversation/domain/conversation_history.dart';
import 'package:photomanager/features/conversation/domain/conversation_message.dart';
import 'package:photomanager/features/conversation/domain/conversation_repository.dart';
import 'package:photomanager/features/conversation/domain/delete_conversation_use_case.dart';
import 'package:photomanager/features/conversation/domain/get_all_conversations_use_case.dart';
import 'package:photomanager/features/conversation/domain/get_conversation_history_use_case.dart';
import 'package:photomanager/features/conversation/domain/save_message_use_case.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return DriftConversationRepository(ref.watch(appDatabaseProvider));
});

final saveMessageUseCaseProvider = Provider<SaveMessageUseCase>((ref) {
  return SaveMessageUseCase(ref.watch(conversationRepositoryProvider));
});

final getConversationHistoryUseCaseProvider =
    Provider<GetConversationHistoryUseCase>((ref) {
  return GetConversationHistoryUseCase(
    ref.watch(conversationRepositoryProvider),
  );
});

final getAllConversationsUseCaseProvider =
    Provider<GetAllConversationsUseCase>((ref) {
  return GetAllConversationsUseCase(ref.watch(conversationRepositoryProvider));
});

final deleteConversationUseCaseProvider =
    Provider<DeleteConversationUseCase>((ref) {
  return DeleteConversationUseCase(ref.watch(conversationRepositoryProvider));
});

final clearHistoryUseCaseProvider = Provider<ClearHistoryUseCase>((ref) {
  return ClearHistoryUseCase(ref.watch(conversationRepositoryProvider));
});

final conversationHistoryListProvider = StateNotifierProvider<
    ConversationHistoryListController,
    AsyncValue<List<ConversationHistory>>>((ref) {
  return ConversationHistoryListController(
    getAllConversations: ref.watch(getAllConversationsUseCaseProvider),
    deleteConversation: ref.watch(deleteConversationUseCaseProvider),
    clearHistory: ref.watch(clearHistoryUseCaseProvider),
  );
});

final conversationDetailProvider = StateNotifierProvider.autoDispose.family<
    ConversationDetailController,
    AsyncValue<List<ConversationMessage>>,
    String>((ref, conversationId) {
  return ConversationDetailController(
    conversationId: conversationId,
    getConversationHistory: ref.watch(getConversationHistoryUseCaseProvider),
  );
});

final seedCallConversationProvider =
    FutureProvider.autoDispose.family<void, ConversationSeedRequest>(
  (ref, request) async {
    final getHistory = ref.watch(getConversationHistoryUseCaseProvider);
    final saveMessage = ref.watch(saveMessageUseCaseProvider);
    final existingMessages = await getHistory(request.conversationId);

    if (existingMessages.isNotEmpty) {
      return;
    }

    // TODO: Remove temporary seed data after realtime integration.
    final now = DateTime.now();
    final seedMessages = [
      ConversationMessage(
        conversationId: request.conversationId,
        participantUsername: request.participantUsername,
        participantDisplayName: request.participantDisplayName,
        senderUsername: 'huy',
        senderDisplayName: 'HUY',
        message: 'Xin chào',
        createdAt: now,
      ),
      ConversationMessage(
        conversationId: request.conversationId,
        participantUsername: request.participantUsername,
        participantDisplayName: request.participantDisplayName,
        senderUsername: request.participantUsername,
        senderDisplayName: request.participantUsername.toUpperCase(),
        message: 'Chào bạn',
        createdAt: now.add(const Duration(seconds: 1)),
      ),
      ConversationMessage(
        conversationId: request.conversationId,
        participantUsername: request.participantUsername,
        participantDisplayName: request.participantDisplayName,
        senderUsername: 'huy',
        senderDisplayName: 'HUY',
        message: 'Bạn khỏe không?',
        createdAt: now.add(const Duration(seconds: 2)),
      ),
    ];

    for (final message in seedMessages) {
      await saveMessage(message);
    }

    ref.invalidate(conversationHistoryListProvider);
    ref.invalidate(conversationDetailProvider(request.conversationId));
  },
);

class ConversationSeedRequest {
  const ConversationSeedRequest({
    required this.participantUsername,
    required this.participantDisplayName,
  });

  final String participantUsername;
  final String participantDisplayName;

  String get conversationId => participantUsername;

  @override
  bool operator ==(Object other) {
    return other is ConversationSeedRequest &&
        other.participantUsername == participantUsername &&
        other.participantDisplayName == participantDisplayName;
  }

  @override
  int get hashCode => Object.hash(participantUsername, participantDisplayName);
}

class ConversationHistoryListController
    extends StateNotifier<AsyncValue<List<ConversationHistory>>> {
  ConversationHistoryListController({
    required GetAllConversationsUseCase getAllConversations,
    required DeleteConversationUseCase deleteConversation,
    required ClearHistoryUseCase clearHistory,
  })  : _getAllConversations = getAllConversations,
        _deleteConversation = deleteConversation,
        _clearHistory = clearHistory,
        super(const AsyncValue.loading()) {
    load();
  }

  final GetAllConversationsUseCase _getAllConversations;
  final DeleteConversationUseCase _deleteConversation;
  final ClearHistoryUseCase _clearHistory;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getAllConversations.call);
  }

  Future<void> deleteConversation(String conversationId) async {
    await _deleteConversation(conversationId);
    await load();
  }

  Future<void> clearAll() async {
    await _clearHistory();
    await load();
  }
}

class ConversationDetailController
    extends StateNotifier<AsyncValue<List<ConversationMessage>>> {
  ConversationDetailController({
    required String conversationId,
    required GetConversationHistoryUseCase getConversationHistory,
  })  : _conversationId = conversationId,
        _getConversationHistory = getConversationHistory,
        super(const AsyncValue.loading()) {
    load();
  }

  final String _conversationId;
  final GetConversationHistoryUseCase _getConversationHistory;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _getConversationHistory(_conversationId),
    );
  }
}
