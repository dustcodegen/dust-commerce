part of 'admin_order_fulfillment_card.dart';

final class _AdminFulfillmentCardHeader extends StatelessWidget {
  const _AdminFulfillmentCardHeader({
    required this.order,
    required this.fulfillment,
    required this.index,
  });

  final AdminOrderFulfillment fulfillment;
  final int index;
  final AdminOrderDetail order;

  @override
  Widget build(BuildContext context) {
    final status = _status(fulfillment);
    return _AdminFulfillmentBorder(
      child: Row(children: [
        Expanded(
          child: Text(
            'Fulfillment #${index + 1}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Tooltip(
          message: DateFormat('dd MMM, yyyy, HH:mm:ss').format(status.date),
          child: Chip(label: Text(status.label)),
        ),
        const SizedBox(width: 8),
        AdminCancelFulfillmentAction(
          order: order,
          fulfillment: fulfillment,
        ),
      ]),
    );
  }
}
