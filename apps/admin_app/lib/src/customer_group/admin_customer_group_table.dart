import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Customer-group table with Medusa's visible column order.
final class AdminCustomerGroupTable extends StatelessWidget {
  /// Creates explicit merchant customer-group rows.
  const AdminCustomerGroupTable({
    required this.customerGroups,
    required this.onOpen,
    super.key,
  });

  /// Rows returned by the protected Admin contract.
  final List<AdminCustomerGroup> customerGroups;

  /// Opens one complete customer-group profile.
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < 960 ? 960 : constraints.maxWidth,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const _AdminCustomerGroupTableHeader(),
              for (final group in customerGroups)
                _AdminCustomerGroupTableRow(group: group, onOpen: onOpen),
            ]),
          ),
        ),
      );
}

final class _AdminCustomerGroupTableHeader extends StatelessWidget {
  const _AdminCustomerGroupTableHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(children: [
          Expanded(flex: 4, child: Text('Name')),
          Expanded(flex: 2, child: Text('Customers')),
          Expanded(flex: 2, child: Text('Created')),
          Expanded(flex: 2, child: Text('Updated')),
          SizedBox(width: 32),
        ]),
      );
}

final class _AdminCustomerGroupTableRow extends StatelessWidget {
  const _AdminCustomerGroupTableRow({
    required this.group,
    required this.onOpen,
  });

  final AdminCustomerGroup group;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onOpen(group.id),
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
              child: Text(group.name, overflow: TextOverflow.ellipsis),
            ),
            Expanded(flex: 2, child: Text('${group.customers.length}')),
            Expanded(flex: 2, child: _AdminCustomerGroupDate(group.createdAt)),
            Expanded(flex: 2, child: _AdminCustomerGroupDate(group.updatedAt)),
            const SizedBox(width: 32),
          ]),
        ),
      );
}

final class _AdminCustomerGroupDate extends StatelessWidget {
  const _AdminCustomerGroupDate(this.value);

  final DateTime value;

  @override
  Widget build(BuildContext context) {
    final local = value.toLocal();
    return Text(DateFormat.yMMMd().add_jm().format(local));
  }
}
