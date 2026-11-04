import 'package:admin_app/src/promotion/admin_promotion_state.dart';
import 'package:admin_app/src/promotion/admin_promotion_table.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Converts promotion-list state into one explicit table body widget.
final class AdminPromotionTableBody extends StatelessWidget {
  /// Creates the loading, error, empty, or populated table surface.
  const AdminPromotionTableBody({
    required this.state,
    required this.onOpen,
    required this.onRetry,
    super.key,
  });

  /// Opens one promotion detail route.
  final ValueChanged<String> onOpen;

  /// Retries the current server page.
  final VoidCallback onRetry;

  /// Current list lifecycle and rows.
  final AdminPromotionState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminPromotionLoadStatus.loading &&
        state.promotions.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.failure case Some(:final value)) {
      return SizedBox(
        height: 120,
        child: Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: Text('$value Retry'),
          ),
        ),
      );
    }
    if (state.promotions.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No promotions found')),
      );
    }
    return Stack(children: [
      AdminPromotionTable(promotions: state.promotions, onOpen: onOpen),
      if (state.status == AdminPromotionLoadStatus.loading)
        const LinearProgressIndicator(minHeight: 2),
    ]);
  }
}
