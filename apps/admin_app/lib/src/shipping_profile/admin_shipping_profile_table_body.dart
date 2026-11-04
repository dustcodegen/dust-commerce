import 'package:admin_app/src/shipping_profile/admin_shipping_profile_state.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_table.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Converts profile-list state into one explicit table body widget.
final class AdminShippingProfileTableBody extends StatelessWidget {
  /// Creates the loading, error, empty, or populated table surface.
  const AdminShippingProfileTableBody({
    required this.state,
    required this.onOpen,
    required this.onDelete,
    required this.onRetry,
    super.key,
  });

  /// Confirms and retires one profile.
  final ValueChanged<AdminShippingProfile> onDelete;

  /// Opens one profile detail route.
  final ValueChanged<String> onOpen;

  /// Retries the current server page.
  final VoidCallback onRetry;

  /// Current list lifecycle and rows.
  final AdminShippingProfileState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminShippingProfileStatus.loading &&
        state.shippingProfiles.isEmpty) {
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
    if (state.shippingProfiles.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No shipping profiles found')),
      );
    }
    return Stack(children: [
      AdminShippingProfileTable(
        shippingProfiles: state.shippingProfiles,
        onOpen: onOpen,
        onDelete: onDelete,
      ),
      if (state.status == AdminShippingProfileStatus.loading)
        const LinearProgressIndicator(minHeight: 2),
    ]);
  }
}
