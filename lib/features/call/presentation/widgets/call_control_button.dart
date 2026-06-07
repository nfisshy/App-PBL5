import 'package:flutter/material.dart';

class CallControlButton extends StatelessWidget {
  const CallControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isActive = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isDestructive
        ? colorScheme.error
        : isActive
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest;
    final foregroundColor = isDestructive
        ? colorScheme.onError
        : isActive
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filled(
            onPressed: onPressed,
            icon: Icon(icon),
            iconSize: 28,
            style: IconButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              minimumSize: const Size.square(56),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
