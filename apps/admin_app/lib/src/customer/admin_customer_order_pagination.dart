import 'package:admin_app/src/customer/admin_customer_detail_state.dart';
import 'package:admin_app/src/customer/admin_customer_detail_view_model.dart';
import 'package:flutter/material.dart';

/// Server-owned paging controls for one customer's order history.
final class AdminCustomerOrderPagination extends StatelessWidget {
  /// Creates paging from the customer-detail state.
  const AdminCustomerOrderPagination({required this.state, super.key});

  /// Current order page and total.
  final AdminCustomerDetailState state;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(children: [
          Text(
            '${state.orderCount == 0 ? 0 : state.orderOffset + 1} — '
            '${state.orderOffset + state.orders.length} of '
            '${state.orderCount} results',
          ),
          const Spacer(),
          TextButton(
            onPressed: state.hasPreviousOrders
                ? context.readAdminCustomerDetailViewModel().previousOrders
                : null,
            child: const Text('Prev'),
          ),
          TextButton(
            onPressed: state.hasNextOrders
                ? context.readAdminCustomerDetailViewModel().nextOrders
                : null,
            child: const Text('Next'),
          ),
        ]),
      );
}
