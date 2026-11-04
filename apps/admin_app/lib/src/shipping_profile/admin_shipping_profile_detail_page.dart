import 'package:admin_app/src/shipping_profile/admin_shipping_profile_delete.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_detail_body.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_detail_failure.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_detail_state.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_detail_view_model.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped shipping-profile detail route.
final class AdminShippingProfileDetailPage extends StatefulWidget {
  /// Creates a detail route for [shippingProfileId].
  const AdminShippingProfileDetailPage({
    required this.shippingProfileId,
    required this.onBack,
    super.key,
  });

  /// Returns to Shipping Profiles.
  final VoidCallback onBack;

  /// Stable fulfillment profile identifier.
  final String shippingProfileId;

  @override
  State<AdminShippingProfileDetailPage> createState() =>
      _AdminShippingProfileDetailPageState();
}

final class _AdminShippingProfileDetailPageState
    extends State<AdminShippingProfileDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .readAdminShippingProfileDetailViewModel()
            .load(widget.shippingProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminShippingProfileDetailViewModel().value;
    return switch (state.shippingProfile) {
      Some(:final value) => AdminShippingProfileDetailBody(
          shippingProfile: value,
          onBack: widget.onBack,
          onDelete: () => _delete(value),
        ),
      None() when state.status == AdminShippingProfileDetailStatus.loading =>
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      None() => AdminShippingProfileDetailFailure(
          state: state,
          onBack: widget.onBack,
          onRetry: () => context
              .readAdminShippingProfileDetailViewModel()
              .load(widget.shippingProfileId),
        ),
    };
  }

  Future<void> _delete(AdminShippingProfile profile) async {
    if (!await confirmAdminShippingProfileDelete(context, profile.name) ||
        !mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final outcome =
        await context.readAdminShippingProfileViewModel().delete(profile.id);
    if (!mounted) return;
    if (outcome == AdminShippingProfileDeleteOutcome.deleted) widget.onBack();
    messenger.showSnackBar(SnackBar(
      content: Text(adminShippingProfileDeleteMessage(outcome, profile.name)),
    ));
  }
}
