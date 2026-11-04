import 'package:admin_app/src/order/admin_order_state.dart';
import 'package:admin_app/src/order/admin_order_view_model.dart';
import 'package:flutter/material.dart';

/// Server-owned order paging controls.
final class AdminOrderPagination extends StatelessWidget {
  /// Creates order-table paging for [state].
  const AdminOrderPagination({required this.state, super.key});

  /// Current list bounds and total.
  final AdminOrderState state;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            Text(
              '${state.count == 0 ? 0 : state.offset + 1} — '
              '${state.offset + state.orders.length} of ${state.count} results',
            ),
            const Spacer(),
            Text('${state.offset ~/ state.limit + 1} of '
                '${(state.count / state.limit).ceil().clamp(1, 1 << 31)} pages'),
            const SizedBox(width: 20),
            TextButton(
              onPressed: state.hasPrevious
                  ? context.readAdminOrderViewModel().previous
                  : null,
              child: const Text('Prev'),
            ),
            TextButton(
              onPressed:
                  state.hasNext ? context.readAdminOrderViewModel().next : null,
              child: const Text('Next'),
            ),
          ],
        ),
      );
}
