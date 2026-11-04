import 'package:admin_app/src/customer/admin_customer_presenter.dart';
import 'package:admin_app/src/customer/admin_customer_actions_menu.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa-compatible customer identity and contact facts.
final class AdminCustomerGeneralSection extends StatelessWidget {
  /// Creates the read-only general section.
  const AdminCustomerGeneralSection({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Complete merchant customer allowlist.
  final AdminCustomerDetail customer;

  /// Opens the Medusa-shaped customer editor.
  final VoidCallback onEdit;

  /// Opens typed confirmation for destructive deletion when available.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shadowColor: const Color(0x12000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: Row(children: [
              Expanded(
                child: Text(
                  adminCustomerDetailText(customer.email),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _AdminCustomerAccountBadge(hasAccount: customer.hasAccount),
              const SizedBox(width: 8),
              AdminCustomerActionsMenu(onEdit: onEdit, onDelete: onDelete),
            ]),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _AdminCustomerDetailRow(
            label: 'Name',
            value: adminCustomerDetailName(customer),
          ),
          _AdminCustomerDetailRow(
            label: 'Company',
            value: adminCustomerDetailText(customer.companyName),
          ),
          _AdminCustomerDetailRow(
            label: 'Phone',
            value: adminCustomerDetailText(customer.phone),
          ),
        ]),
      );
}

final class _AdminCustomerDetailRow extends StatelessWidget {
  const _AdminCustomerDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        child: Row(children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ]),
      );
}

final class _AdminCustomerAccountBadge extends StatelessWidget {
  const _AdminCustomerAccountBadge({required this.hasAccount});

  final bool hasAccount;

  @override
  Widget build(BuildContext context) {
    final color =
        hasAccount ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        hasAccount ? 'Registered' : 'Guest',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
