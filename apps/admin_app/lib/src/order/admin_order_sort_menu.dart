part of 'admin_order_toolbar.dart';

final class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.order});

  final AdminOrderOrder order;

  @override
  Widget build(BuildContext context) => PopupMenuButton<AdminOrderOrder>(
        tooltip: 'Sort orders',
        initialValue: order,
        onSelected: context.readAdminOrderViewModel().orderBy,
        icon: const Icon(Icons.sort_rounded, size: 18),
        itemBuilder: (context) => [
          for (final value in AdminOrderOrder.values)
            PopupMenuItem(value: value, child: Text(_label(value))),
        ],
      );

  String _label(AdminOrderOrder value) => switch (value) {
        AdminOrderOrder.displayIdAsc => 'Order: low to high',
        AdminOrderOrder.displayIdDesc => 'Order: high to low',
        AdminOrderOrder.createdAtAsc => 'Created: oldest first',
        AdminOrderOrder.createdAtDesc => 'Created: newest first',
        AdminOrderOrder.updatedAtAsc => 'Updated: oldest first',
        AdminOrderOrder.updatedAtDesc => 'Updated: newest first',
      };
}
