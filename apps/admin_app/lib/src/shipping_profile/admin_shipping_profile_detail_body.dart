import 'package:admin_app/src/shipping_profile/admin_shipping_profile_general_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Loaded profile detail composition.
final class AdminShippingProfileDetailBody extends StatelessWidget {
  /// Creates a loaded detail route.
  const AdminShippingProfileDetailBody({
    required this.shippingProfile,
    required this.onBack,
    required this.onDelete,
    super.key,
  });

  /// Returns to the profile table.
  final VoidCallback onBack;

  /// Opens typed deletion confirmation.
  final VoidCallback onDelete;

  /// Explicit loaded profile.
  final AdminShippingProfile shippingProfile;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Shipping Profiles'),
                  ),
                  const SizedBox(height: 6),
                  AdminShippingProfileGeneralSection(
                    shippingProfile: shippingProfile,
                    onDelete: onDelete,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
