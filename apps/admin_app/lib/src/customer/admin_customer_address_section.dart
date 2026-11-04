import 'package:admin_app/src/customer/admin_customer_address_actions_menu.dart';
import 'package:admin_app/src/customer/admin_customer_presenter.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Active reusable destinations on Medusa's customer-detail side column.
final class AdminCustomerAddressSection extends StatelessWidget {
  /// Creates the read-only address section.
  const AdminCustomerAddressSection({
    required this.customer,
    required this.onAdd,
    required this.onDelete,
    super.key,
  });

  /// Complete profile and active address book.
  final AdminCustomerDetail customer;

  /// Opens the focused address creation form.
  final VoidCallback onAdd;

  /// Opens typed confirmation for one address when deletion is available.
  final ValueChanged<AdminCustomerAddress>? onDelete;

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(children: [
              Expanded(
                child: Text(
                  'Addresses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(onPressed: onAdd, child: const Text('Add')),
            ]),
          ),
          if (customer.addresses.isEmpty)
            const _AdminCustomerNoAddresses()
          else
            for (final address in customer.addresses)
              _AdminCustomerAddressRow(
                address: address,
                onDelete: onDelete,
              ),
        ]),
      );
}

final class _AdminCustomerNoAddresses extends StatelessWidget {
  const _AdminCustomerNoAddresses();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: const Text('No addresses to show.'),
      );
}

final class _AdminCustomerAddressRow extends StatelessWidget {
  const _AdminCustomerAddressRow({
    required this.address,
    required this.onDelete,
  });

  final AdminCustomerAddress address;
  final ValueChanged<AdminCustomerAddress>? onDelete;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adminCustomerAddressTitle(address),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  adminCustomerAddressLines(address),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (address.isDefaultShipping || address.isDefaultBilling) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, children: [
                    if (address.isDefaultShipping)
                      const Chip(label: Text('Default shipping')),
                    if (address.isDefaultBilling)
                      const Chip(label: Text('Default billing')),
                  ]),
                ],
              ],
            ),
          ),
          AdminCustomerAddressActionsMenu(
            onDelete: onDelete == null ? null : () => onDelete!(address),
          ),
        ]),
      );
}
