import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 88,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Icon(
        Icons.sign_language,
        size: size * 0.55,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
