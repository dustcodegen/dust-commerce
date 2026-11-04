import 'package:admin_app/src/promotion/admin_promotion_detail_body.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_failure.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_state.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_view_model.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped promotion detail route.
final class AdminPromotionDetailPage extends StatefulWidget {
  /// Creates a detail route for [promotionId].
  const AdminPromotionDetailPage({
    required this.promotionId,
    required this.onBack,
    super.key,
  });

  /// Returns to Promotions.
  final VoidCallback onBack;

  /// Stable promotion identifier.
  final String promotionId;

  @override
  State<AdminPromotionDetailPage> createState() =>
      _AdminPromotionDetailPageState();
}

final class _AdminPromotionDetailPageState
    extends State<AdminPromotionDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.readAdminPromotionDetailViewModel().load(widget.promotionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminPromotionDetailViewModel().value;
    return switch (state.promotion) {
      Some(:final value) => AdminPromotionDetailBody(
          promotion: value,
          onBack: widget.onBack,
        ),
      None() when state.status == AdminPromotionDetailStatus.loading =>
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      None() => AdminPromotionDetailFailure(
          state: state,
          onBack: widget.onBack,
          onRetry: () => context
              .readAdminPromotionDetailViewModel()
              .load(widget.promotionId),
        ),
    };
  }
}
