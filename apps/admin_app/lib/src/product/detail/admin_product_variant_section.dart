import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Inventory variants matching Medusa's detail table shape.
final class AdminProductVariantSection extends StatelessWidget {
  /// Creates the variant table.
  const AdminProductVariantSection({
    required this.variants,
    required this.onEdit,
    required this.onEditPrices,
    required this.onEditStock,
    required this.onUnavailable,
    super.key,
  });

  /// Opens the supported variant-detail editor.
  final ValueChanged<AdminProductVariant> onEdit;

  /// Opens the source-shaped focused pricing editor.
  final ValueChanged<AdminProductVariant> onEditPrices;

  /// Opens the source-shaped product stock grid.
  final VoidCallback onEditStock;

  /// Inventory-bearing merchant variants.
  final List<AdminProductVariant> variants;

  /// Reports controls whose write API is not implemented yet.
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) => AdminProductDetailSection(
        title: 'Variants',
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: onEditStock,
              child: const Text('Edit stock'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onUnavailable,
              child: const Text('Create'),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onUnavailable,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add filter'),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 180,
                    child: TextField(
                      onSubmitted: (_) => onUnavailable(),
                      decoration: const InputDecoration(
                        hintText: 'Search variants',
                        prefixIcon: Icon(Icons.search_rounded, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            if (variants.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No variants'),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 660,
                  child: Column(
                    children: [
                      const _VariantHeader(),
                      for (final variant in variants)
                        _VariantRow(
                          variant: variant,
                          onEdit: onEdit,
                          onEditPrices: onEditPrices,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
}

final class _VariantHeader extends StatelessWidget {
  const _VariantHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(
          children: [
            Expanded(flex: 3, child: Text('Variant')),
            Expanded(flex: 2, child: Text('SKU')),
            Expanded(child: Text('Stock')),
            Expanded(child: Text('Inventory')),
          ],
        ),
      );
}

final class _VariantRow extends StatelessWidget {
  const _VariantRow({
    required this.variant,
    required this.onEdit,
    required this.onEditPrices,
  });

  final ValueChanged<AdminProductVariant> onEdit;
  final ValueChanged<AdminProductVariant> onEditPrices;
  final AdminProductVariant variant;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onEdit(variant),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.only(left: 20, right: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(variant.title)),
              Expanded(
                flex: 2,
                child: adminDetailText(context, variant.sku),
              ),
              Expanded(child: Text('${variant.inventoryQuantity}')),
              Expanded(
                child: Text(variant.manageInventory ? 'Managed' : 'Unmanaged'),
              ),
              PopupMenuButton<_VariantAction>(
                tooltip: 'Variant actions',
                icon: const Icon(Icons.more_horiz_rounded, size: 18),
                onSelected: (action) => switch (action) {
                  _VariantAction.edit => onEdit(variant),
                  _VariantAction.prices => onEditPrices(variant),
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _VariantAction.edit,
                    child: Text('Edit variant'),
                  ),
                  PopupMenuItem(
                    value: _VariantAction.prices,
                    child: Text('Edit prices'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

enum _VariantAction { edit, prices }
