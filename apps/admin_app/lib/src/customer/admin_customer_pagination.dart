import 'package:admin_app/src/customer/admin_customer_state.dart';
import 'package:admin_app/src/customer/admin_customer_view_model.dart';
import 'package:flutter/material.dart';

/// Server-owned 20-row customer paging controls.
final class AdminCustomerPagination extends StatelessWidget {
  /// Creates customer paging controls for [state].
  const AdminCustomerPagination({required this.state, super.key});

  /// Current customer list bounds and total.
  final AdminCustomerState state;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(children: [
          Text(_range),
          const Spacer(),
          Text('$_currentPage of $_pageCount pages'),
          const SizedBox(width: 18),
          TextButton(
            onPressed: state.hasPrevious
                ? context.readAdminCustomerViewModel().previous
                : null,
            child: const Text('Prev'),
          ),
          TextButton(
            onPressed: state.hasNext
                ? context.readAdminCustomerViewModel().next
                : null,
            child: const Text('Next'),
          ),
        ]),
      );

  int get _currentPage =>
      state.count == 0 ? 1 : state.offset ~/ state.limit + 1;

  int get _pageCount =>
      state.count == 0 ? 1 : (state.count / state.limit).ceil();

  String get _range => state.count == 0
      ? '0 of 0 results'
      : '${state.offset + 1} — ${state.offset + state.customers.length} of '
          '${state.count} results';
}
