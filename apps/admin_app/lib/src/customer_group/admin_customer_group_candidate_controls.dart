import 'package:admin_app/src/customer/admin_customer_sort.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_candidate_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Search, account, and order controls for the Add Customers surface.
final class AdminCustomerGroupCandidateControls extends StatelessWidget {
  /// Creates candidate controls independent from the Customers route.
  const AdminCustomerGroupCandidateControls({
    required this.search,
    required this.state,
    required this.selectedCount,
    required this.onSearch,
    required this.onAccount,
    required this.onOrder,
    super.key,
  });

  /// Applies a registered, guest, or all-account constraint.
  final ValueChanged<Option<bool>> onAccount;

  /// Applies one server-owned ordering.
  final ValueChanged<AdminCustomerOrder> onOrder;

  /// Runs the normalized search from the first page.
  final ValueChanged<String> onSearch;

  /// Candidate search controller owned by the focus form.
  final TextEditingController search;

  /// Number of new memberships selected across pages.
  final int selectedCount;

  /// Current candidate-list controls.
  final AdminCustomerGroupCandidateState state;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final selection = Text(
            selectedCount == 0 ? 'Select customers' : '$selectedCount selected',
            style: Theme.of(context).textTheme.labelMedium,
          );
          final controls = Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: constraints.maxWidth < 520 ? 180 : 240,
              child: TextField(
                controller: search,
                autofocus: true,
                onSubmitted: onSearch,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search_rounded, size: 17),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _CandidateAccountFilter(
                value: state.hasAccount, onChanged: onAccount),
            AdminCustomerSort(value: state.order, onChanged: onOrder),
          ]);
          if (constraints.maxWidth < 680) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [selection, const SizedBox(height: 10), controls],
            );
          }
          return Row(children: [Expanded(child: selection), controls]);
        },
      );
}

enum _CandidateAccount { all, registered, guest }

final class _CandidateAccountFilter extends StatelessWidget {
  const _CandidateAccountFilter({required this.value, required this.onChanged});

  final ValueChanged<Option<bool>> onChanged;
  final Option<bool> value;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_CandidateAccount>(
        tooltip: 'Filter customers',
        initialValue: switch (value) {
          Some(value: true) => _CandidateAccount.registered,
          Some(value: false) => _CandidateAccount.guest,
          None() => _CandidateAccount.all,
        },
        onSelected: (selection) => onChanged(switch (selection) {
          _CandidateAccount.all => const None(),
          _CandidateAccount.registered => const Some(true),
          _CandidateAccount.guest => const Some(false),
        }),
        itemBuilder: (context) => const [
          PopupMenuItem(
              value: _CandidateAccount.all, child: Text('All accounts')),
          PopupMenuItem(
            value: _CandidateAccount.registered,
            child: Text('Registered'),
          ),
          PopupMenuItem(value: _CandidateAccount.guest, child: Text('Guest')),
        ],
        icon: const Icon(Icons.filter_list_rounded, size: 18),
      );
}
