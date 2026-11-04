import 'package:admin_app/src/customer_group/admin_customer_group_customer_row.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Selectable customer table shared by group members and add candidates.
final class AdminCustomerGroupCustomerTable extends StatelessWidget {
  /// Creates a source-shaped customer selection table.
  const AdminCustomerGroupCustomerTable({
    required this.customers,
    required this.selected,
    required this.disabled,
    required this.busy,
    required this.onToggle,
    required this.onTogglePage,
    this.onOpen,
    this.onRemove,
    super.key,
  });

  /// Blocks interaction while a membership command is active.
  final bool busy;

  /// Customer ids already in the group and therefore not selectable.
  final Set<String> disabled;

  /// Rows on the current server-owned page.
  final List<AdminCustomer> customers;

  /// Opens a customer route when supplied.
  final ValueChanged<String>? onOpen;

  /// Removes a single membership when supplied.
  final ValueChanged<String>? onRemove;

  /// Toggles one selectable row.
  final ValueChanged<String> onToggle;

  /// Toggles every selectable row on the current page.
  final ValueChanged<bool> onTogglePage;

  /// Selected candidate or member ids.
  final Set<String> selected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < 820 ? 820 : constraints.maxWidth,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _CustomerTableHeader(
                customers: customers,
                selected: selected,
                disabled: disabled,
                busy: busy,
                onTogglePage: onTogglePage,
              ),
              for (final customer in customers)
                AdminCustomerGroupCustomerRow(
                  customer: customer,
                  selected: selected.contains(customer.id),
                  disabled: disabled.contains(customer.id),
                  busy: busy,
                  onToggle: () => onToggle(customer.id),
                  onOpen: onOpen == null ? null : () => onOpen!(customer.id),
                  onRemove:
                      onRemove == null ? null : () => onRemove!(customer.id),
                ),
            ]),
          ),
        ),
      );
}

final class _CustomerTableHeader extends StatelessWidget {
  const _CustomerTableHeader({
    required this.customers,
    required this.selected,
    required this.disabled,
    required this.busy,
    required this.onTogglePage,
  });

  final bool busy;
  final List<AdminCustomer> customers;
  final Set<String> disabled;
  final ValueChanged<bool> onTogglePage;
  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    final selectable = customers.where((row) => !disabled.contains(row.id));
    final selectedCount =
        selectable.where((row) => selected.contains(row.id)).length;
    final all = selectable.isNotEmpty && selectedCount == selectable.length;
    final some = selectedCount > 0 && !all;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Row(children: [
        SizedBox(
          width: 44,
          child: Checkbox(
            tristate: true,
            value: all ? true : (some ? null : false),
            onChanged:
                busy || selectable.isEmpty ? null : (_) => onTogglePage(!all),
          ),
        ),
        const Expanded(flex: 4, child: Text('Email')),
        const Expanded(flex: 3, child: Text('Name')),
        const Expanded(flex: 2, child: Text('Account')),
        const Expanded(flex: 2, child: Text('Created')),
        const SizedBox(width: 44),
      ]),
    );
  }
}
