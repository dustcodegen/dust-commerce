import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Product-type identity and actions matching Medusa's first detail card.
final class AdminProductTypeGeneralSection extends StatelessWidget {
  /// Creates the identity card.
  const AdminProductTypeGeneralSection({
    required this.productType,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Confirms and retires this type.
  final VoidCallback onDelete;

  /// Opens the existing edit drawer.
  final VoidCallback onEdit;

  /// Explicit product-type response.
  final AdminProductType productType;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Row(children: [
            Expanded(
              child: Text(
                productType.value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Product type actions',
              icon: const Icon(Icons.more_horiz_rounded, size: 18),
              onSelected: (value) => value == 'delete' ? onDelete() : onEdit(),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ),
          ]),
        ),
      );
}
