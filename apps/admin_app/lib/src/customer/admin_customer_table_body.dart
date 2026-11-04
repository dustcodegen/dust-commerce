import 'package:admin_app/src/customer/admin_customer_state.dart';
import 'package:admin_app/src/customer/admin_customer_table.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Converts customer-list state into one explicit table body.
final class AdminCustomerTableBody extends StatelessWidget {
  /// Creates the loading, error, empty, or populated surface.
  const AdminCustomerTableBody({
    required this.state,
    required this.onRetry,
    required this.onOpen,
    super.key,
  });

  /// Retries the current server page.
  final VoidCallback onRetry;

  /// Opens a selected customer profile.
  final ValueChanged<String> onOpen;

  /// Current customer list lifecycle and rows.
  final AdminCustomerState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminCustomerListStatus.loading &&
        state.customers.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.failure case Some(:final value) when state.customers.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: Text('$value Retry'),
          ),
        ),
      );
    }
    if (state.customers.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('Your customers will show up here.')),
      );
    }
    return Stack(children: [
      AdminCustomerTable(customers: state.customers, onOpen: onOpen),
      if (state.status == AdminCustomerListStatus.loading)
        const LinearProgressIndicator(minHeight: 2),
    ]);
  }
}
