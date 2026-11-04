import 'package:admin_app/src/customer/admin_customer_presenter.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// One selectable row in a customer-group member table.
final class AdminCustomerGroupCustomerRow extends StatelessWidget {
  /// Creates a customer row with optional navigation and removal.
  const AdminCustomerGroupCustomerRow({
    required this.customer,
    required this.selected,
    required this.disabled,
    required this.busy,
    required this.onToggle,
    this.onOpen,
    this.onRemove,
    super.key,
  });

  /// Disables row selection while a command is active.
  final bool busy;

  /// Merchant-safe customer summary.
  final AdminCustomer customer;

  /// Whether this existing member is intentionally preselected and disabled.
  final bool disabled;

  /// Opens the existing customer route when available.
  final VoidCallback? onOpen;

  /// Removes this row from the group when available.
  final VoidCallback? onRemove;

  /// Toggles row selection.
  final VoidCallback onToggle;

  /// Whether this selectable row is checked.
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(children: [
          SizedBox(
              width: 44,
              child: _CustomerCheckbox(
                checked: selected || disabled,
                disabled: disabled,
                busy: busy,
                onToggle: onToggle,
              )),
          Expanded(
            child: InkWell(
              onTap: onOpen,
              child: Row(children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    adminCustomerEmail(customer),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    adminCustomerName(customer),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(flex: 2, child: _CustomerAccount(customer: customer)),
                Expanded(
                  flex: 2,
                  child: Tooltip(
                    message: adminCustomerCreatedFull(customer.createdAt),
                    child: Text(adminCustomerCreated(customer.createdAt)),
                  ),
                ),
              ]),
            ),
          ),
          SizedBox(
            width: 44,
            child: onRemove == null
                ? null
                : PopupMenuButton<_CustomerRowAction>(
                    tooltip: 'Customer actions',
                    enabled: !busy,
                    icon: const Icon(Icons.more_horiz_rounded, size: 18),
                    onSelected: (action) => switch (action) {
                      _CustomerRowAction.edit => onOpen?.call(),
                      _CustomerRowAction.remove => onRemove?.call(),
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _CustomerRowAction.edit,
                        enabled: onOpen != null,
                        child: const Row(children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ]),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: _CustomerRowAction.remove,
                        child: Row(children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Remove',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
          ),
        ]),
      );
}

final class _CustomerCheckbox extends StatelessWidget {
  const _CustomerCheckbox({
    required this.checked,
    required this.disabled,
    required this.busy,
    required this.onToggle,
  });

  final bool busy;
  final bool checked;
  final bool disabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final checkbox = Checkbox(
      value: checked,
      onChanged: busy || disabled ? null : (_) => onToggle(),
    );
    if (!disabled) return checkbox;
    return Tooltip(
      message: 'The customer has already been added to the group.',
      child: checkbox,
    );
  }
}

final class _CustomerAccount extends StatelessWidget {
  const _CustomerAccount({required this.customer});

  final AdminCustomer customer;

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: customer.hasAccount
                ? const Color(0xFF22C55E)
                : const Color(0xFFF59E0B),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            adminCustomerAccount(customer),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]);
}

enum _CustomerRowAction { edit, remove }
