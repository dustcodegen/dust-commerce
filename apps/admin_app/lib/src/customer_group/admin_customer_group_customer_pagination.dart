import 'package:admin_app/src/customer_group/admin_customer_group_detail_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_view_model.dart';
import 'package:flutter/material.dart';

/// Paging controls for the group-scoped customer table.
final class AdminCustomerGroupCustomerPagination extends StatelessWidget {
  /// Creates controls from the server-owned page metadata.
  const AdminCustomerGroupCustomerPagination({required this.state, super.key});

  /// Current independently pageable customer state.
  final AdminCustomerGroupDetailState state;

  @override
  Widget build(BuildContext context) {
    final start = state.customerCount == 0 ? 0 : state.customerOffset + 1;
    final end = state.customerOffset + state.customers.length;
    final busy =
        state.customersStatus == AdminCustomerGroupCustomersStatus.loading;
    final viewModel = context.readAdminCustomerGroupDetailViewModel();
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(children: [
        Expanded(
          child: Text(
            '$start–$end of ${state.customerCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        IconButton(
          tooltip: 'Previous page',
          onPressed: !busy && state.hasPreviousCustomers
              ? viewModel.previousCustomers
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed:
              !busy && state.hasNextCustomers ? viewModel.nextCustomers : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ]),
    );
  }
}
