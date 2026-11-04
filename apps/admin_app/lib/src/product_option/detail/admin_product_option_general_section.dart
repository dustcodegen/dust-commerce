import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Product-option identity and exclusivity matching Medusa's first card.
final class AdminProductOptionGeneralSection extends StatelessWidget {
  /// Creates the option identity card.
  const AdminProductOptionGeneralSection({
    required this.productOption,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Confirms and deletes this option.
  final VoidCallback onDelete;

  /// Opens the edit focus surface.
  final VoidCallback onEdit;

  /// Allowlisted option detail.
  final AdminProductOptionDetail productOption;

  @override
  Widget build(BuildContext context) => AdminProductDetailSection(
        title: productOption.title,
        action: PopupMenuButton<String>(
          tooltip: 'Product option actions',
          icon: const Icon(Icons.more_horiz_rounded, size: 18),
          onSelected: (value) => switch (value) {
            'delete' => onDelete(),
            _ => onEdit(),
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(children: [
            const Expanded(child: Text('Type')),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _TypeBadge(isExclusive: productOption.isExclusive),
              ),
            ),
          ]),
        ),
      );
}

final class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isExclusive});

  final bool isExclusive;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isExclusive
              ? Theme.of(context).colorScheme.surfaceContainerHigh
              : Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E3A5F)
                  : const Color(0xFFDBEAFE),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(isExclusive ? 'Product-specific' : 'Global'),
      );
}
