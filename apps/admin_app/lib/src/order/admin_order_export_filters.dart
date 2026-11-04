import 'package:admin_app/src/order/admin_order_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Read-only summary of the exact order query sent to the export route.
final class AdminOrderExportFilters extends StatelessWidget {
  /// Creates the source-shaped filter summary.
  const AdminOrderExportFilters({required this.state, super.key});

  /// Current order-table state.
  final AdminOrderState state;

  @override
  Widget build(BuildContext context) {
    final filters = _filters();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filters', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Only orders matching the current table filters are exported.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        if (filters.isEmpty)
          const _ReadOnlyFilter(label: 'Orders', value: 'All orders')
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
        if (state.regionIds.isNotEmpty)
          (
            label: 'Region',
            value: _regionNames(state.regions, state.regionIds),
          ),
        if (state.salesChannelIds.isNotEmpty)
          (
            label: 'Sales channel',
            value: _salesChannelNames(
              state.salesChannels,
              state.salesChannelIds,
            ),
          ),
        if (!state.createdAt.isEmpty)
          (label: 'Created', value: _dateFilter(state.createdAt)),
        if (!state.updatedAt.isEmpty)
          (label: 'Updated', value: _dateFilter(state.updatedAt)),
        (label: 'Order', value: _order(state.order)),
      ];
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

String _order(AdminOrderOrder value) => switch (value) {
      AdminOrderOrder.displayIdAsc => 'Order number ascending',
      AdminOrderOrder.displayIdDesc => 'Order number descending',
      AdminOrderOrder.createdAtAsc => 'Created oldest',
      AdminOrderOrder.createdAtDesc => 'Created newest',
      AdminOrderOrder.updatedAtAsc => 'Updated oldest',
      AdminOrderOrder.updatedAtDesc => 'Updated newest',
    };

String _title(String value) =>
    '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';

String _regionNames(List<AdminRegion> regions, List<String> selected) {
  final names = [
    for (final region in regions)
      if (selected.contains(region.id)) region.name,
  ];
  return names.isEmpty ? selected.join(', ') : names.join(', ');
}

String _salesChannelNames(
  List<AdminSalesChannel> channels,
  List<String> selected,
) {
  final names = [
    for (final channel in channels)
      if (selected.contains(channel.id)) channel.name,
  ];
  return names.isEmpty ? selected.join(', ') : names.join(', ');
}
