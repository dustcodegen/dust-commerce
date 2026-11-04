import 'package:admin_app/src/shipping_profile/admin_shipping_profile_detail_state.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Retry surface for a profile detail that could not load.
final class AdminShippingProfileDetailFailure extends StatelessWidget {
  /// Creates one failure state.
  const AdminShippingProfileDetailFailure({
    required this.state,
    required this.onBack,
    required this.onRetry,
    super.key,
  });

  /// Returns to the profile list.
  final VoidCallback onBack;

  /// Retries the routed identifier.
  final VoidCallback onRetry;

  /// Current failure state.
  final AdminShippingProfileDetailState state;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(switch (state.failure) {
            Some(:final value) => value,
            None() => 'Unable to load this shipping profile.',
          }),
          const SizedBox(height: 12),
          Row(mainAxisSize: MainAxisSize.min, children: [
            OutlinedButton(
              onPressed: onBack,
              child: const Text('Shipping Profiles'),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ]),
        ]),
      );
}
