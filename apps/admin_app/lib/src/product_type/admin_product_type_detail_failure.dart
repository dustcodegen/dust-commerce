import 'package:flutter/material.dart';

/// Renders the recoverable product-type detail failure state.
final class AdminProductTypeDetailFailure extends StatelessWidget {
  /// Creates a detail failure state.
  const AdminProductTypeDetailFailure({
    required this.message,
    required this.onBack,
    required this.onRetry,
    super.key,
  });

  /// Display-safe failure message.
  final String message;

  /// Returns to the product-type list.
  final VoidCallback onBack;

  /// Retries the detail request.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message),
          const SizedBox(height: 12),
          Row(mainAxisSize: MainAxisSize.min, children: [
            OutlinedButton(onPressed: onBack, child: const Text('Types')),
            const SizedBox(width: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ]),
        ]),
      );
}
