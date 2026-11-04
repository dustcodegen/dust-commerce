import 'package:admin_app/src/promotion/admin_promotion_detail_state.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Retry surface for a promotion detail that could not load.
final class AdminPromotionDetailFailure extends StatelessWidget {
  /// Creates one failure state.
  const AdminPromotionDetailFailure({
    required this.state,
    required this.onBack,
    required this.onRetry,
    super.key,
  });

  /// Returns to the promotion list.
  final VoidCallback onBack;

  /// Retries the routed identifier.
  final VoidCallback onRetry;

  /// Current failure state.
  final AdminPromotionDetailState state;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(switch (state.failure) {
            Some(:final value) => value,
            None() => 'Unable to load this promotion.',
          }),
          const SizedBox(height: 12),
          Row(mainAxisSize: MainAxisSize.min, children: [
            OutlinedButton(
              onPressed: onBack,
              child: const Text('Promotions'),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ]),
        ]),
      );
}
