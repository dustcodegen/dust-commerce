part of 'admin_order_toolbar.dart';

final class _AddFilter extends StatelessWidget {
  const _AddFilter({required this.state});

  final AdminOrderState state;

  @override
  Widget build(BuildContext context) => MenuAnchor(
        menuChildren: [
          if (state.regionIds.isEmpty && state.regions.isNotEmpty)
            _RegionFilterSubmenu(
              regions: state.regions,
              selected: state.regionIds,
              onChanged: context.readAdminOrderViewModel().filterByRegions,
            ),
          if (state.salesChannelIds.isEmpty && state.salesChannels.isNotEmpty)
            _SalesChannelFilterSubmenu(
              salesChannels: state.salesChannels,
              selected: state.salesChannelIds,
              onChanged:
                  context.readAdminOrderViewModel().filterBySalesChannels,
            ),
          for (final status in AdminOrderStatus.values)
            MenuItemButton(
              onPressed: () => _select(context, 'status:${status.name}'),
              child: Text('Status: ${_title(status.name)}'),
            ),
          if (state.createdAt.isEmpty)
            MenuItemButton(
              onPressed: () => _select(context, 'created'),
              child: const Text('Created: last 30 days'),
            ),
          if (state.updatedAt.isEmpty)
            MenuItemButton(
              onPressed: () => _select(context, 'updated'),
              child: const Text('Updated: last 30 days'),
            ),
        ],
        builder: (context, controller, child) => OutlinedButton(
          onPressed: controller.isOpen ? controller.close : controller.open,
          child: const Text('Add filter'),
        ),
      );

  void _select(BuildContext context, String value) {
    final orders = context.readAdminOrderViewModel();
    final since = Some(DateTime.now().subtract(const Duration(days: 30)));
    if (value == 'created') {
      orders.filterByCreatedAt(from: since, to: const None());
      return;
    }
    if (value == 'updated') {
      orders.filterByUpdatedAt(from: since, to: const None());
      return;
    }
    final status = AdminOrderStatus.values.byName(
      value.substring('status:'.length),
    );
    final selected = state.statuses.contains(status)
        ? state.statuses.where((value) => value != status).toList()
        : [...state.statuses, status];
    orders.filterByStatuses(selected);
  }

  String _title(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';
}

final class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onRemove});

  final Widget label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 4, 7),
              child: label,
            ),
            IconButton(
              tooltip: 'Remove filter',
              onPressed: onRemove,
              constraints: const BoxConstraints.tightFor(width: 28, height: 32),
              icon: const Icon(Icons.close_rounded, size: 14),
            ),
          ],
        ),
      );
}
