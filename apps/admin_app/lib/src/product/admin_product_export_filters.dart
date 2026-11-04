import 'package:admin_app/src/product/admin_product_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Read-only summary of the current product-table query exported by the API.
final class AdminProductExportFilters extends StatelessWidget {
  /// Creates a Medusa-style filter summary.
  const AdminProductExportFilters({required this.state, super.key});

  /// Current product table state.
  final AdminProductState state;

  @override
  Widget build(BuildContext context) {
    final filters = _filters();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filters', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Only products matching the current table filters are exported.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        if (filters.isEmpty)
          _ReadOnlyFilter(label: 'Products', value: 'All products')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final filter in filters)
                _ReadOnlyFilter(label: filter.label, value: filter.value),
            ],
          ),
      ],
    );
  }

  List<({String label, String value})> _filters() => [
        if (state.query.isNotEmpty) (label: 'Search', value: state.query),
        if (state.statuses.isNotEmpty)
          (
            label: 'Status',
            value: state.statuses.map((value) => _title(value.name)).join(', '),
          ),
        if (state.typeIds.isNotEmpty)
          (label: 'Type', value: _labels(state.typeIds, _types)),
        if (state.tagIds.isNotEmpty)
          (label: 'Tag', value: _labels(state.tagIds, _tags)),
        if (!state.createdAt.isEmpty)
          (label: 'Created', value: _dateFilter(state.createdAt)),
        if (!state.updatedAt.isEmpty)
          (label: 'Updated', value: _dateFilter(state.updatedAt)),
        (label: 'Order', value: _order(state.order)),
      ];

  Map<String, String> get _tags => {
        for (final tag in state.productTags) tag.id: tag.value,
      };

  Map<String, String> get _types => {
        for (final type in state.productTypes) type.id: type.value,
      };
}

final class _ReadOnlyFilter extends StatelessWidget {
  const _ReadOnlyFilter({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('$label · $value'),
      );
}

String _labels(List<String> ids, Map<String, String> labels) =>
    ids.map((id) => labels[id] ?? id).join(', ');

String _dateFilter(AdminDateFilter value) {
  final parts = <String>[];
  value.greaterThanOrEqual.match(
    some: (date) => parts.add('from ${_date(date)}'),
    none: () {},
  );
  value.lessThanOrEqual.match(
    some: (date) => parts.add('to ${_date(date)}'),
    none: () {},
  );
  return parts.join(' ');
}

String _date(DateTime value) =>
    value.toLocal().toIso8601String().split('T').first;

String _order(AdminProductOrder value) => switch (value) {
      AdminProductOrder.titleAsc => 'Title A–Z',
      AdminProductOrder.titleDesc => 'Title Z–A',
      AdminProductOrder.createdAtAsc => 'Created oldest',
      AdminProductOrder.createdAtDesc => 'Created newest',
      AdminProductOrder.updatedAtAsc => 'Updated oldest',
      AdminProductOrder.updatedAtDesc => 'Updated newest',
    };

String _title(String value) =>
    '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
