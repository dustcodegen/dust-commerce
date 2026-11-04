import 'package:admin_app/src/customer/admin_customer_detail_state.dart';
import 'package:admin_app/src/customer/admin_customer_detail_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_order_pagination.dart';
import 'package:admin_app/src/customer/admin_customer_order_table.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped searchable order history for one customer.
final class AdminCustomerOrderSection extends StatefulWidget {
  /// Creates the customer-owned order table.
  const AdminCustomerOrderSection({
    required this.state,
    required this.onOpenOrder,
    super.key,
  });

  /// Opens one complete order route.
  final ValueChanged<String> onOpenOrder;

  /// Current customer-owned order state.
  final AdminCustomerDetailState state;

  @override
  State<AdminCustomerOrderSection> createState() =>
      _AdminCustomerOrderSectionState();
}

final class _AdminCustomerOrderSectionState
    extends State<AdminCustomerOrderSection> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.state.orderQuery);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: LayoutBuilder(builder: (context, constraints) {
              final title = Text(
                'Orders',
                style: Theme.of(context).textTheme.titleMedium,
              );
              final controls = Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  width: constraints.maxWidth < 520 ? 190 : 220,
                  child: TextField(
                    controller: _search,
                    onSubmitted:
                        context.readAdminCustomerDetailViewModel().searchOrders,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search_rounded, size: 17),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _AdminCustomerOrderSort(order: widget.state.order),
              ]);
              if (constraints.maxWidth < 620) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 10), controls],
                );
              }
              return Row(children: [Expanded(child: title), controls]);
            }),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _AdminCustomerOrderBody(
            state: widget.state,
            onOpen: widget.onOpenOrder,
          ),
          AdminCustomerOrderPagination(state: widget.state),
        ]),
      );
}

final class _AdminCustomerOrderSort extends StatelessWidget {
  const _AdminCustomerOrderSort({required this.order});

  final AdminOrderOrder order;

  @override
  Widget build(BuildContext context) => PopupMenuButton<AdminOrderOrder>(
        tooltip: 'Sort orders',
        initialValue: order,
        onSelected: (value) => context
            .readAdminCustomerDetailViewModel()
            .loadOrders(order: value, offset: 0),
        itemBuilder: (context) => [
          for (final value in AdminOrderOrder.values)
            PopupMenuItem(value: value, child: Text(_label(value))),
        ],
        icon: const Icon(Icons.swap_vert_rounded, size: 18),
      );

  String _label(AdminOrderOrder value) => switch (value) {
        AdminOrderOrder.displayIdAsc => 'Order number A–Z',
        AdminOrderOrder.displayIdDesc => 'Order number Z–A',
        AdminOrderOrder.createdAtAsc => 'Created oldest first',
        AdminOrderOrder.createdAtDesc => 'Created newest first',
        AdminOrderOrder.updatedAtAsc => 'Updated oldest first',
        AdminOrderOrder.updatedAtDesc => 'Updated newest first',
      };
}

final class _AdminCustomerOrderBody extends StatelessWidget {
  const _AdminCustomerOrderBody({required this.state, required this.onOpen});

  final ValueChanged<String> onOpen;
  final AdminCustomerDetailState state;

  @override
  Widget build(BuildContext context) {
    if (state.ordersStatus == AdminCustomerOrdersStatus.loading &&
        state.orders.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.orderFailure case Some(:final value) when state.orders.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: OutlinedButton(
            onPressed: context.readAdminCustomerDetailViewModel().loadOrders,
            child: Text('$value Retry'),
          ),
        ),
      );
    }
    if (state.orders.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No orders to show.')),
      );
    }
    return Stack(children: [
      AdminCustomerOrderTable(orders: state.orders, onOpen: onOpen),
      if (state.ordersStatus == AdminCustomerOrdersStatus.loading)
        const LinearProgressIndicator(minHeight: 2),
    ]);
  }
}
