import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Compact product-type table matching Medusa's visible columns.
final class AdminProductTypeTable extends StatelessWidget {
  /// Creates the allowlisted product-type table.
  const AdminProductTypeTable({
    required this.productTypes,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Opens the edit drawer for one row.
  final ValueChanged<AdminProductType> onEdit;

  /// Opens one complete product-type detail route.
  final ValueChanged<String> onOpen;

  /// Confirms and retires one row.
  final ValueChanged<AdminProductType> onDelete;

  /// Rows returned by the explicit Admin contract.
  final List<AdminProductType> productTypes;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Header(),
          for (final productType in productTypes)
            _Row(
              productType: productType,
              onOpen: onOpen,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
        ],
      );
}

final class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(
          children: [
            Expanded(flex: 5, child: Text('Value')),
            Expanded(flex: 3, child: Text('Created')),
            Expanded(flex: 3, child: Text('Updated')),
            SizedBox(width: 32),
          ],
        ),
      );
}

final class _Row extends StatelessWidget {
  const _Row({
    required this.productType,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final ValueChanged<AdminProductType> onDelete;
  final ValueChanged<AdminProductType> onEdit;
  final ValueChanged<String> onOpen;
  final AdminProductType productType;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onOpen(productType.id),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text(productType.value)),
                Expanded(flex: 3, child: Text(_date(productType.createdAt))),
                Expanded(flex: 3, child: Text(_date(productType.updatedAt))),
                SizedBox(
                  width: 32,
                  child: PopupMenuButton<String>(
                    tooltip: 'Product type actions',
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz_rounded, size: 17),
                    onSelected: (value) => value == 'delete'
                        ? onDelete(productType)
                        : onEdit(productType),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  String _date(DateTime value) => DateFormat.yMMMd().format(value.toLocal());
}
