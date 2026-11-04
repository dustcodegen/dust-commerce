import 'package:admin_app/src/customer_group/admin_customer_group_customer_table.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_view_model.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Loading, failure, empty, and populated group-customer table body.
final class AdminCustomerGroupCustomerBody extends StatelessWidget {
  /// Creates the explicit customer-section body.
  const AdminCustomerGroupCustomerBody({
    required this.state,
    required this.onOpen,
    required this.selected,
    required this.busy,
    required this.onToggle,
    required this.onTogglePage,
    required this.onRemove,
    super.key,
  });

  /// Whether a membership command blocks table actions.
  final bool busy;

  /// Opens one customer detail route.
  final ValueChanged<String> onOpen;

  /// Removes one row after confirmation.
  final ValueChanged<String> onRemove;

  /// Toggles one row.
  final ValueChanged<String> onToggle;

  /// Toggles every row on the current page.
  final ValueChanged<bool> onTogglePage;

  /// Selected customer ids across group pages.
  final Set<String> selected;

  /// Current customer section state.
  final AdminCustomerGroupDetailState state;

  @override
  Widget build(BuildContext context) {
    if (state.customersStatus == AdminCustomerGroupCustomersStatus.loading &&
        state.customers.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.customerFailure case Some(:final value)
        when state.customers.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: OutlinedButton(
            onPressed:
                context.readAdminCustomerGroupDetailViewModel().loadCustomers,
            child: Text('$value Retry'),
          ),
        ),
      );
    }
    if (state.customers.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text("This group doesn't have customers.")),
      );
    }
    return Stack(children: [
      AdminCustomerGroupCustomerTable(
        customers: state.customers,
        selected: selected,
        disabled: const {},
        busy: busy,
        onToggle: onToggle,
        onTogglePage: onTogglePage,
        onOpen: onOpen,
        onRemove: onRemove,
      ),
      if (state.customersStatus == AdminCustomerGroupCustomersStatus.loading)
        const LinearProgressIndicator(minHeight: 2),
    ]);
  }
}
