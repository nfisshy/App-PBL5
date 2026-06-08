import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/core/network/api_client.dart';
import 'package:photomanager/core/network/mock_api_client.dart';
import 'package:photomanager/core/network/network_status.dart';
import 'package:photomanager/core/services/api/api_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return MockApiClient();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(apiClientProvider));
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) async* {
  yield NetworkStatus.checking;
  await Future<void>.delayed(const Duration(milliseconds: 300));
  yield NetworkStatus.connected;
});
