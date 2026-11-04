import 'package:admin_app/src/customer_group/admin_customer_group_candidate_controls.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_candidate_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_customer_table.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Full-height candidate table content for Medusa's Add Customers flow.
final class AdminCustomerGroupCandidateContent extends StatelessWidget {
  /// Creates candidate controls, table states, and pagination.
  const AdminCustomerGroupCandidateContent({
    required this.state,
    required this.search,
    required this.selected,
    required this.existing,
    required this.busy,
    required this.onSearch,
    required this.onAccount,
    required this.onOrder,
    required this.onToggle,
    required this.onTogglePage,
    required this.onPrevious,
    required this.onNext,
    required this.onRetry,
    super.key,
  });

  /// Whether a membership command blocks interaction.
  final bool busy;

  /// Current member ids shown checked and disabled.
  final Set<String> existing;

  /// Applies a registered, guest, or all-account filter.
  final ValueChanged<Option<bool>> onAccount;

  /// Loads the next candidate page.
  final VoidCallback onNext;

  /// Applies one server-owned ordering.
  final ValueChanged<AdminCustomerOrder> onOrder;

  /// Loads the previous candidate page.
  final VoidCallback onPrevious;

  /// Retries candidate loading.
  final VoidCallback onRetry;

  /// Searches candidates from the first page.
  final ValueChanged<String> onSearch;

  /// Toggles one candidate id.
  final ValueChanged<String> onToggle;

  /// Toggles selectable candidates on the current page.
  final ValueChanged<bool> onTogglePage;

  /// Search controller owned by the focus form.
  final TextEditingController search;

  /// New customer ids selected across candidate pages.
  final Set<String> selected;

  /// Current candidate page and query state.
  final AdminCustomerGroupCandidateState state;

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: AdminCustomerGroupCandidateControls(
            search: search,
            state: state,
            selectedCount: selected.length,
            onSearch: onSearch,
            onAccount: onAccount,
            onOrder: onOrder,
          ),
        ),
        Divider(height: 1, color: Theme.of(context).dividerColor),
        Expanded(
          child: Stack(children: [
            _CandidateBody(
              state: state,
              selected: selected,
              existing: existing,
              busy: busy,
              onToggle: onToggle,
              onTogglePage: onTogglePage,
              onRetry: onRetry,
            ),
            if (state.status == AdminCustomerGroupCandidateStatus.loading &&
                state.customers.isNotEmpty)
              const LinearProgressIndicator(minHeight: 2),
          ]),
        ),
        _CandidatePagination(
          state: state,
          busy: busy,
          onPrevious: onPrevious,
          onNext: onNext,
        ),
      ]);
}

final class _CandidateBody extends StatelessWidget {
  const _CandidateBody({
    required this.state,
    required this.selected,
    required this.existing,
    required this.busy,
    required this.onToggle,
    required this.onTogglePage,
    required this.onRetry,
  });

  final bool busy;
  final Set<String> existing;
  final VoidCallback onRetry;
  final ValueChanged<String> onToggle;
  final ValueChanged<bool> onTogglePage;
  final Set<String> selected;
  final AdminCustomerGroupCandidateState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminCustomerGroupCandidateStatus.loading &&
        state.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (state.failure case Some(:final value) when state.customers.isEmpty) {
      return Center(
        child: OutlinedButton(onPressed: onRetry, child: Text('$value Retry')),
      );
    }
    if (state.customers.isEmpty) {
      return const Center(child: Text('Create a customer first.'));
    }
    return SingleChildScrollView(
      child: AdminCustomerGroupCustomerTable(
        customers: state.customers,
        selected: selected,
        disabled: existing,
        busy: busy,
        onToggle: onToggle,
        onTogglePage: onTogglePage,
      ),
    );
  }
}

final class _CandidatePagination extends StatelessWidget {
  const _CandidatePagination({
    required this.state,
    required this.busy,
    required this.onPrevious,
    required this.onNext,
  });

  final bool busy;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final AdminCustomerGroupCandidateState state;

  @override
  Widget build(BuildContext context) {
    final start = state.count == 0 ? 0 : state.offset + 1;
    final end = state.offset + state.customers.length;
    final loading = state.status == AdminCustomerGroupCandidateStatus.loading;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(children: [
        Expanded(
          child: Text(
            '$start–$end of ${state.count}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        IconButton(
          tooltip: 'Previous page',
          onPressed: !busy && !loading && state.hasPrevious ? onPrevious : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: !busy && !loading && state.hasNext ? onNext : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ]),
    );
  }
}
