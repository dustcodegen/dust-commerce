import 'package:admin_app/src/promotion/admin_promotion_general_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Loaded promotion detail composition.
final class AdminPromotionDetailBody extends StatelessWidget {
  /// Creates a loaded detail route.
  const AdminPromotionDetailBody({
    required this.promotion,
    required this.onBack,
    super.key,
  });

  /// Returns to the promotion table.
  final VoidCallback onBack;

  /// Explicit loaded promotion.
  final AdminPromotion promotion;

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
                    label: const Text('Promotions'),
                  ),
                  const SizedBox(height: 6),
                  AdminPromotionGeneralSection(promotion: promotion),
                ],
              ),
            ),
          ),
        ],
      );
}
