import 'package:flutter/material.dart';

/// Failure fallback for a customer-group detail route.
final class AdminCustomerGroupDetailFailure extends StatelessWidget {
  /// Creates navigation and retry actions around [message].
  const AdminCustomerGroupDetailFailure({
    required this.message,
    required this.onBack,
    required this.onRetry,
    super.key,
  });

  /// Display-safe detail request failure.
  final String message;

  /// Returns to the customer-group list.
  final VoidCallback onBack;

  /// Retries the current detail request.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            OutlinedButton(
              onPressed: onBack,
              child: const Text('Customer Groups'),
            ),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ]),
        ]),
      );
}
