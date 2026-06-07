import 'package:flutter/material.dart';
import 'package:photomanager/features/realtime/domain/connection_status.dart';

class ConnectionStatusBadge extends StatelessWidget {
  const ConnectionStatusBadge({
    required this.status,
    super.key,
  });

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ConnectionStatus.connected => Colors.green,
      ConnectionStatus.connecting => Colors.orange,
      ConnectionStatus.reconnecting => Colors.amber,
      ConnectionStatus.disconnected => Colors.red,
    };

    return Semantics(
      label: 'Realtime status: ${status.label}',
      child: Chip(
        avatar: Icon(Icons.circle, color: color, size: 12),
        label: Text(status.label),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

extension ConnectionStatusLabel on ConnectionStatus {
  String get label => switch (this) {
        ConnectionStatus.disconnected => 'Disconnected',
        ConnectionStatus.connecting => 'Connecting',
        ConnectionStatus.connected => 'Connected',
        ConnectionStatus.reconnecting => 'Reconnecting',
      };
}
