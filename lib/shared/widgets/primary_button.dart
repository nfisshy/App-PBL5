import 'package:flutter/material.dart';
import 'package:photomanager/shared/widgets/app_loading_indicator.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const AppLoadingIndicator(size: 20, strokeWidth: 2)
            : Text(label),
      ),
    );
  }
}
