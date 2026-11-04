import 'package:admin_app/src/product/admin_product_detail_state.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Recoverable full-page state for an unavailable product detail.
final class AdminProductDetailFailure extends StatelessWidget {
  /// Creates a display-safe failure with navigation and retry actions.
  const AdminProductDetailFailure({
    required this.state,
    required this.onBack,
    required this.onRetry,
    super.key,
  });

  /// Returns to the product table.
  final VoidCallback onBack;

  /// Retries the current product request.
  final VoidCallback onRetry;

  /// Current typed product-detail state.
  final AdminProductDetailState state;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(switch (state.failure) {
              Some(value: final message) => message,
              None() => 'Unable to load this product.',
            }),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: onBack, child: const Text('Products')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ],
        ),
      );
}
