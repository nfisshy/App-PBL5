import 'package:flutter/material.dart';

class CallActionButton extends StatelessWidget {
  const CallActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(backgroundColor: color),
      ),
    );
  }
}
