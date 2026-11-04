import 'package:admin_app/src/product/admin_product_actions.dart';
import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa-compatible general product facts.
final class AdminProductGeneralSection extends StatelessWidget {
  /// Creates the general detail section.
  const AdminProductGeneralSection({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Confirms and retires the loaded product.
  final VoidCallback onDelete;

  /// Complete admin product allowlist.
  final AdminProductDetail product;

  /// Opens the supported general-details editor.
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shadowColor: const Color(0x12000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _ProductStatus(value: product.status),
                  const SizedBox(width: 8),
                  AdminProductActions(
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            AdminProductDetailRow(
              label: 'Description',
              value: adminDetailText(context, product.description),
            ),
            AdminProductDetailRow(
              label: 'Subtitle',
              value: adminDetailText(context, product.subtitle),
            ),
            AdminProductDetailRow(
              label: 'Handle',
              value: adminDetailText(context, '/${product.handle}'),
            ),
            AdminProductDetailRow(
              label: 'Material',
              value: adminDetailText(context, product.material),
            ),
            AdminProductDetailRow(
              label: 'Discountable',
              value: Text(product.discountable ? 'True' : 'False'),
            ),
          ],
        ),
      );
}

final class _ProductStatus extends StatelessWidget {
  const _ProductStatus({required this.value});

  final AdminProductLifecycle value;

  @override
  Widget build(BuildContext context) {
    final published = value == AdminProductLifecycle.published;
    final color = published ? const Color(0xFF16A34A) : const Color(0xFF71717A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _titleCase(value.name),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _titleCase(String input) => input.isEmpty
      ? 'Unknown'
      : '${input[0].toUpperCase()}${input.substring(1).toLowerCase()}';
}
