import 'package:admin_app/src/customer_group/admin_customer_group_detail_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Search, account, and order controls for one group's customers.
final class AdminCustomerGroupCustomerControls extends StatelessWidget {
  /// Creates source-shaped customer table controls.
  const AdminCustomerGroupCustomerControls({
    required this.search,
    required this.state,
    required this.selectedCount,
    required this.busy,
    required this.onRemove,
    super.key,
  });

  /// Whether a membership command blocks table actions.
  final bool busy;

  /// Removes the current selection after confirmation.
  final VoidCallback onRemove;

  /// Search input owned by the parent stateful section.
  final TextEditingController search;

  /// Number of selected member rows across pages.
  final int selectedCount;

  /// Current customer query controls.
  final AdminCustomerGroupDetailState state;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final command = selectedCount == 0
              ? const SizedBox.shrink()
              : TextButton.icon(
                  onPressed: busy ? null : onRemove,
                  icon: const Icon(Icons.remove_circle_outline, size: 17),
                  label: Text('Remove ($selectedCount)'),
                );
          final controls = Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: constraints.maxWidth < 520 ? 180 : 220,
              child: TextField(
                controller: search,
                onSubmitted: context
                    .readAdminCustomerGroupDetailViewModel()
                    .searchCustomers,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search_rounded, size: 17),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _AccountFilterButton(value: state.hasAccount),
            _CustomerSortButton(order: state.order),
          ]);
          if (constraints.maxWidth < 650) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [command, const SizedBox(height: 10), controls],
            );
          }
          return Row(children: [Expanded(child: command), controls]);
        },
      );
}

enum _AccountFilter { all, registered, guest }

final class _AccountFilterButton extends StatelessWidget {
  const _AccountFilterButton({required this.value});

  final Option<bool> value;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_AccountFilter>(
        tooltip: 'Filter customers',
        initialValue: switch (value) {
          Some(value: true) => _AccountFilter.registered,
          Some(value: false) => _AccountFilter.guest,
          None() => _AccountFilter.all,
        },
        onSelected: (selection) =>
            context.readAdminCustomerGroupDetailViewModel().loadCustomers(
                  hasAccount: switch (selection) {
                    _AccountFilter.all => const None(),
                    _AccountFilter.registered => const Some(true),
                    _AccountFilter.guest => const Some(false),
                  },
                  offset: 0,
                ),
        itemBuilder: (context) => const [
          PopupMenuItem(value: _AccountFilter.all, child: Text('All accounts')),
          PopupMenuItem(
            value: _AccountFilter.registered,
            child: Text('Registered'),
          ),
          PopupMenuItem(value: _AccountFilter.guest, child: Text('Guest')),
        ],
        icon: const Icon(Icons.filter_list_rounded, size: 18),
      );
}

final class _CustomerSortButton extends StatelessWidget {
  const _CustomerSortButton({required this.order});

  final AdminCustomerOrder order;

  @override
  Widget build(BuildContext context) => PopupMenuButton<AdminCustomerOrder>(
        tooltip: 'Sort customers',
        initialValue: order,
        onSelected: (value) => context
            .readAdminCustomerGroupDetailViewModel()
            .loadCustomers(order: value, offset: 0),
        itemBuilder: (context) => [
          for (final value in AdminCustomerOrder.values)
            PopupMenuItem(value: value, child: Text(_orderLabel(value))),
        ],
        icon: const Icon(Icons.swap_vert_rounded, size: 18),
      );
}

String _orderLabel(AdminCustomerOrder value) => switch (value) {
      AdminCustomerOrder.emailAsc => 'Email A–Z',
      AdminCustomerOrder.emailDesc => 'Email Z–A',
      AdminCustomerOrder.firstNameAsc => 'First name A–Z',
      AdminCustomerOrder.firstNameDesc => 'First name Z–A',
      AdminCustomerOrder.lastNameAsc => 'Last name A–Z',
      AdminCustomerOrder.lastNameDesc => 'Last name Z–A',
      AdminCustomerOrder.hasAccountAsc => 'Guest first',
      AdminCustomerOrder.hasAccountDesc => 'Registered first',
      AdminCustomerOrder.createdAtAsc => 'Created oldest first',
      AdminCustomerOrder.createdAtDesc => 'Created newest first',
      AdminCustomerOrder.updatedAtAsc => 'Updated oldest first',
      AdminCustomerOrder.updatedAtDesc => 'Updated newest first',
    };
