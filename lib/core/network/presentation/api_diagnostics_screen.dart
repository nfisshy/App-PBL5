import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/core/network/api_constants.dart';
import 'package:photomanager/core/network/api_providers.dart';
import 'package:photomanager/core/network/mock_api_client.dart';
import 'package:photomanager/core/network/network_status.dart';

class ApiDiagnosticsScreen extends ConsumerWidget {
  const ApiDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(networkStatusProvider).valueOrNull ?? NetworkStatus.checking;
    final client = ref.watch(apiClientProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('API Diagnostics')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _DiagnosticCard(
                  title: 'Configuration',
                  children: [
                    _DiagnosticRow(
                      label: 'Base URL',
                      value: ApiConstants.baseApiUrl,
                    ),
                    _DiagnosticRow(
                      label: 'Audio URL',
                      value: ApiConstants.audioApiUrl,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DiagnosticCard(
                  title: 'Mock API Status',
                  children: [
                    _DiagnosticRow(
                      label: 'Client',
                      value: client is MockApiClient
                          ? 'MockApiClient'
                          : client.runtimeType.toString(),
                    ),
                    _DiagnosticRow(
                      label: 'Network',
                      value: status.label,
                    ),
                    const _DiagnosticRow(
                      label: 'Real Requests',
                      value: 'Disabled',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DiagnosticCard(
                  title: 'Available Endpoints',
                  children: ApiConstants.availableEndpoints
                      .map(
                        (endpoint) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.route_outlined),
                          title: Text(endpoint),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagnosticCard extends StatelessWidget {
  const _DiagnosticCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(
            child: SelectableText(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

extension NetworkStatusLabel on NetworkStatus {
  String get label => switch (this) {
        NetworkStatus.connected => 'Connected',
        NetworkStatus.disconnected => 'Disconnected',
        NetworkStatus.checking => 'Checking',
      };
}
