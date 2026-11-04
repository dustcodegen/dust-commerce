import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:admin_app/src/product_option/detail/admin_product_option_section_footer.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Ranked values matching Medusa's product-option values table.
final class AdminProductOptionValuesSection extends StatefulWidget {
  /// Creates the values card.
  const AdminProductOptionValuesSection({
    required this.values,
    required this.onEdit,
    super.key,
  });

  /// Opens the complete option editor.
  final VoidCallback onEdit;

  /// Active values in merchant-defined display order.
  final List<AdminProductOptionValue> values;

  @override
  State<AdminProductOptionValuesSection> createState() =>
      _AdminProductOptionValuesSectionState();
}

final class _AdminProductOptionValuesSectionState
    extends State<AdminProductOptionValuesSection> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visible = widget.values
        .where((item) => item.value.toLowerCase().contains(_query))
        .toList();
    return AdminProductDetailSection(
      title: 'Values',
      action: SizedBox(
        width: 184,
        child: TextField(
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()),
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search_rounded, size: 17),
          ),
        ),
      ),
      child: widget.values.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child:
                  Center(child: Text('There are no values for this option.')),
            )
          : Column(
              children: [
                const _ValueHeader(),
                for (final value in visible)
                  _ValueRow(value: value.value, onEdit: widget.onEdit),
                AdminProductOptionSectionFooter(count: visible.length),
              ],
            ),
    );
  }
}

final class _ValueHeader extends StatelessWidget {
  const _ValueHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 43,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        alignment: Alignment.centerLeft,
        child: const Text('Values'),
      );
}

final class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.value, required this.onEdit});

  final VoidCallback onEdit;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        height: 43,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(children: [
          Expanded(child: Text(value)),
          IconButton(
            tooltip: 'Edit values',
            onPressed: onEdit,
            icon: const Icon(Icons.more_horiz_rounded, size: 17),
          ),
        ]),
      );
}
