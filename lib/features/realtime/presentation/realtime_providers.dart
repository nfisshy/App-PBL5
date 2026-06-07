import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/core/services/realtime/realtime_service.dart';
import 'package:photomanager/features/realtime/data/mock_realtime_repository.dart';
import 'package:photomanager/features/realtime/domain/connection_status.dart';
import 'package:photomanager/features/realtime/domain/realtime_event.dart';
import 'package:photomanager/features/realtime/domain/realtime_repository.dart';

final realtimeRepositoryProvider = Provider<RealtimeRepository>((ref) {
  return MockRealtimeRepository();
});

final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService(ref.watch(realtimeRepositoryProvider));
  ref.onDispose(service.disconnect);
  return service;
});

final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  service.connect();
  return service.connectionStatusStream();
});

final realtimeEventProvider = StreamProvider<RealtimeEvent>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  service.connect();
  return service.eventStream();
});
