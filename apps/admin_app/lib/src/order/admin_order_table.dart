import 'package:admin_app/src/core/admin_money.dart';
import 'package:admin_app/src/order/admin_order_fulfillment_status.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'admin_order_table_cells.dart';

/// Desktop-first order table matching Medusa's source column order.
final class AdminOrderTable extends StatelessWidget {
  /// Creates the explicitly allowlisted merchant order table.
  const AdminOrderTable({
    required this.orders,
    required this.onOpen,
    super.key,
  });

  /// Opens one complete merchant order detail.
  final ValueChanged<String> onOpen;

  /// Rows returned by the Admin order contract.
  final List<AdminOrder> orders;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < 1120 ? 1120 : constraints.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _OrderHeader(),
                for (final order in orders)
                  _OrderRow(order: order, onOpen: onOpen),
              ],
            ),
          ),
        ),
      );
}

final class _OrderHeader extends StatelessWidget {
  const _OrderHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(
          children: [
            Expanded(flex: 2, child: Text('Order')),
            Expanded(flex: 3, child: Text('Date')),
            Expanded(flex: 4, child: Text('Customer')),
            Expanded(flex: 3, child: Text('Sales channel')),
            Expanded(flex: 3, child: Text('Payment')),
            Expanded(flex: 3, child: Text('Fulfillment')),
            Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('Total'),
                )),
            SizedBox(width: 52),
          ],
        ),
      );
}

final class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.onOpen});

  final ValueChanged<String> onOpen;
  final AdminOrder order;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onOpen(order.id),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _MutedText(value: '#${order.displayId}'),
              ),
              Expanded(
                flex: 3,
                child: Tooltip(
                  message: DateFormat.yMMMd().add_jm().format(
                        order.createdAt.toLocal(),
                      ),
                  child: Text(
                    DateFormat.yMMMd().format(order.createdAt.toLocal()),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  order.customerName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 3,
                child: order.salesChannelName.match(
                  some: (name) => Text(name, overflow: TextOverflow.ellipsis),
                  none: () => const _MutedText(value: '-'),
                ),
              ),
              Expanded(
                flex: 3,
                child: _PaymentStatus(value: order.paymentStatus),
              ),
              Expanded(
                flex: 3,
                child: _FulfillmentStatus(value: order.fulfillmentStatus),
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
              SizedBox(
                width: 52,
                child: Align(
                  child: Tooltip(
                    message: order.countryCode?.toUpperCase() ?? 'No country',
                    child: Text(order.countryCode?.toUpperCase() ?? '—'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
