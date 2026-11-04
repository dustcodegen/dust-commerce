import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa's compact global product-option table.
final class AdminProductOptionTable extends StatelessWidget {
  /// Creates the allowlisted option table.
  const AdminProductOptionTable({
    required this.productOptions,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  /// Confirms and deletes one unused option.
  final ValueChanged<AdminProductOptionSummary> onDelete;

  /// Opens one complete product-option detail.
  final ValueChanged<String> onOpen;

  /// Rows returned by the explicit admin contract.
  final List<AdminProductOptionSummary> productOptions;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _OptionHeader(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productOptions.length,
            itemBuilder: (context, index) => _OptionRow(
              productOption: productOptions[index],
              onOpen: onOpen,
              onDelete: onDelete,
            ),
          ),
        ],
      );
}

final class _OptionHeader extends StatelessWidget {
  const _OptionHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(
          children: [
            Expanded(flex: 5, child: Text('Title')),
            Expanded(flex: 3, child: Text('Values')),
            Expanded(flex: 2, child: Text('Status')),
            SizedBox(width: 32),
          ],
        ),
      );
}

final class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.productOption,
    required this.onOpen,
    required this.onDelete,
  });

  final ValueChanged<AdminProductOptionSummary> onDelete;
  final ValueChanged<String> onOpen;
  final AdminProductOptionSummary productOption;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onOpen(productOption.id),
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
                Expanded(flex: 5, child: Text(productOption.title)),
                Expanded(
                  flex: 3,
                  child: Text(_valueLabel(productOption.valueCount)),
                ),
                const Expanded(flex: 2, child: _GlobalBadge()),
                SizedBox(
                  width: 32,
                  child: PopupMenuButton<String>(
                    tooltip: 'Product option actions',
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz_rounded, size: 17),
                    onSelected: (value) => switch (value) {
                      'delete' => onDelete(productOption),
                      _ => onOpen(productOption.id),
                    },
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

  String _valueLabel(int count) => switch (count) {
        0 => '—',
        1 => '1 value',
        _ => '$count values',
      };
}

final class _GlobalBadge extends StatelessWidget {
  const _GlobalBadge();

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E3A5F)
                : const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            'Global',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFF1D4ED8),
                ),
          ),
        ),
      );
}
