import 'package:admin_app/src/customer_group/admin_customer_group_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_table.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Converts customer-group state into one explicit table body.
final class AdminCustomerGroupTableBody extends StatelessWidget {
  /// Creates the loading, error, empty, or populated surface.
  const AdminCustomerGroupTableBody({
    required this.state,
    required this.onOpen,
    required this.onRetry,
    super.key,
  });

  /// Retries the current server page.
  final VoidCallback onRetry;

  /// Opens one complete customer-group profile.
  final ValueChanged<String> onOpen;

  /// Current customer-group list lifecycle and rows.
  final AdminCustomerGroupState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminCustomerGroupStatus.loading &&
        state.customerGroups.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.failure case Some(:final value)
        when state.customerGroups.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: Text('$value Retry'),
          ),
        ),
      );
    }
    if (state.customerGroups.isEmpty) {
      return _AdminCustomerGroupEmpty(filtered: _hasQueryOrFilter(state));
    }
    return Stack(children: [
      AdminCustomerGroupTable(
        customerGroups: state.customerGroups,
        onOpen: onOpen,
      ),
      if (state.status == AdminCustomerGroupStatus.loading)
        const LinearProgressIndicator(minHeight: 2),
    ]);
  }
}

bool _hasQueryOrFilter(AdminCustomerGroupState state) =>
    state.query.isNotEmpty || state.hasFilters;

final class _AdminCustomerGroupEmpty extends StatelessWidget {
  const _AdminCustomerGroupEmpty({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 180,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              filtered ? 'No results' : 'No customer groups',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              filtered
                  ? 'No customer groups match the current filter criteria.'
                  : 'There are no customer groups to display.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ]),
        ),
      );
}
