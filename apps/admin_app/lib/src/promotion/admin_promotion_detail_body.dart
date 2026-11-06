import 'package:admin_app/src/promotion/admin_promotion_general_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Loaded promotion detail composition.
final class AdminPromotionDetailBody extends StatelessWidget {
  /// Creates a loaded detail route.
  const AdminPromotionDetailBody({
    required this.promotion,
    required this.onBack,
    required this.onDelete,
    required this.deleting,
    super.key,
  });

  /// Returns to the promotion table.
  final VoidCallback onBack;

  /// Retires this promotion after confirmation.
  final VoidCallback onDelete;

  /// Whether the retirement request is in flight.
  final bool deleting;

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
                  Row(
                    children: [
                      Expanded(
                        child:
                            AdminPromotionGeneralSection(promotion: promotion),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: deleting ? null : onDelete,
                        icon: deleting
                            ? const SizedBox.square(
                                dimension: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
