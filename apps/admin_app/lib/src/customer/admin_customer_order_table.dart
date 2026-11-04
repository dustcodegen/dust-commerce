import 'package:admin_app/src/core/admin_money.dart';
import 'package:admin_app/src/order/admin_order_status_badge.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Customer-owned order table with Medusa's customer column removed.
final class AdminCustomerOrderTable extends StatelessWidget {
  /// Creates the order rows and existing order-detail navigation.
  const AdminCustomerOrderTable({
    required this.orders,
    required this.onOpen,
    super.key,
  });

  /// Opens one complete merchant order.
  final ValueChanged<String> onOpen;

  /// Orders constrained to the selected customer by the server.
  final List<AdminOrder> orders;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < 920 ? 920 : constraints.maxWidth,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const _AdminCustomerOrderHeader(),
              for (final order in orders)
                _AdminCustomerOrderRow(order: order, onOpen: onOpen),
            ]),
          ),
        ),
      );
}

final class _AdminCustomerOrderHeader extends StatelessWidget {
  const _AdminCustomerOrderHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(children: [
          Expanded(flex: 2, child: Text('Order')),
          Expanded(flex: 3, child: Text('Date')),
          Expanded(flex: 3, child: Text('Sales channel')),
          Expanded(flex: 3, child: Text('Payment')),
          Expanded(flex: 3, child: Text('Fulfillment')),
          Expanded(
            flex: 3,
            child:
                Align(alignment: Alignment.centerRight, child: Text('Total')),
          ),
        ]),
      );
}

final class _AdminCustomerOrderRow extends StatelessWidget {
  const _AdminCustomerOrderRow({required this.order, required this.onOpen});

  final ValueChanged<String> onOpen;
  final AdminOrder order;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onOpen(order.id),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(children: [
            Expanded(flex: 2, child: Text('#${order.displayId}')),
            Expanded(
              flex: 3,
              child: Tooltip(
                message: DateFormat.yMMMd()
                    .add_jm()
                    .format(order.createdAt.toLocal()),
                child:
                    Text(DateFormat.yMMMd().format(order.createdAt.toLocal())),
              ),
            ),
            Expanded(
              flex: 3,
              child: order.salesChannelName.match(
                some: (name) => Text(name, overflow: TextOverflow.ellipsis),
                none: () => const Text('—'),
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AdminOrderPaymentBadge(status: order.paymentStatus),
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AdminOrderFulfillmentBadge(
                  status: order.fulfillmentStatus,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${order.currencyCode.toUpperCase()} '
                  '${formatMinorUnits(order.total, order.currencyCode)}',
                ),
              ),
            ),
          ]),
        ),
      );
}
