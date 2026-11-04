import 'package:admin_app/src/customer/admin_customer_presenter.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Customer table with Medusa's visible column order.
final class AdminCustomerTable extends StatelessWidget {
  /// Creates explicit merchant customer rows.
  const AdminCustomerTable({
    required this.customers,
    required this.onOpen,
    super.key,
  });

  /// Rows returned by the protected Admin contract.
  final List<AdminCustomer> customers;

  /// Opens one complete customer profile.
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < 760 ? 760 : constraints.maxWidth,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const _AdminCustomerTableHeader(),
              for (final customer in customers)
                _AdminCustomerTableRow(customer: customer, onOpen: onOpen),
            ]),
          ),
        ),
      );
}

final class _AdminCustomerTableHeader extends StatelessWidget {
  const _AdminCustomerTableHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(children: [
          Expanded(flex: 4, child: Text('Email')),
          Expanded(flex: 3, child: Text('Name')),
          Expanded(flex: 2, child: Text('Account')),
          Expanded(flex: 2, child: Text('Created')),
        ]),
      );
}

final class _AdminCustomerTableRow extends StatelessWidget {
  const _AdminCustomerTableRow({
    required this.customer,
    required this.onOpen,
  });

  final AdminCustomer customer;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onOpen(customer.id),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
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
            Expanded(flex: 2, child: _AdminCustomerAccount(customer: customer)),
            Expanded(
              flex: 2,
              child: Tooltip(
                message: adminCustomerCreatedFull(customer.createdAt),
                child: Text(adminCustomerCreated(customer.createdAt)),
              ),
            ),
          ]),
        ),
      );
}

final class _AdminCustomerAccount extends StatelessWidget {
  const _AdminCustomerAccount({required this.customer});

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
