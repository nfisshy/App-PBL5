import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/network/api_providers.dart';
import 'package:photomanager/core/network/mock_api_client.dart';
import 'package:photomanager/core/network/network_status.dart';

void main() {
  test('providers expose mock client, service, and status transitions',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final statuses = <NetworkStatus>[];
    final connected = Completer<void>();
    final subscription = container.listen(
      networkStatusProvider,
      (previous, next) {
        final status = next.valueOrNull;
        if (status != null) {
          statuses.add(status);
          if (status == NetworkStatus.connected && !connected.isCompleted) {
            connected.complete();
          }
        }
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(container.read(apiClientProvider), isA<MockApiClient>());
    expect(container.read(apiServiceProvider), isNotNull);
    await connected.future;
    expect(
      statuses,
      containsAllInOrder([NetworkStatus.checking, NetworkStatus.connected]),
    );
  });
}
