part of 'admin_order_table.dart';

final class _MutedText extends StatelessWidget {
  const _MutedText({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
}

final class _PaymentStatus extends StatelessWidget {
  const _PaymentStatus({required this.value});

  final AdminOrderPaymentStatus value;

  @override
  Widget build(BuildContext context) => _StatusCell(
        label: switch (value) {
          AdminOrderPaymentStatus.awaiting => 'Awaiting',
          AdminOrderPaymentStatus.captured => 'Captured',
          AdminOrderPaymentStatus.refunded => 'Refunded',
        },
        color: switch (value) {
          AdminOrderPaymentStatus.awaiting => const Color(0xFFF59E0B),
          AdminOrderPaymentStatus.captured => const Color(0xFF22C55E),
          AdminOrderPaymentStatus.refunded => const Color(0xFF71717A),
        },
      );
}

final class _FulfillmentStatus extends StatelessWidget {
  const _FulfillmentStatus({required this.value});

  final AdminOrderFulfillmentStatus value;

  @override
  Widget build(BuildContext context) => _StatusCell(
        label: adminOrderFulfillmentLabel(value),
        color: adminOrderFulfillmentColor(value),
      );
}

final class _StatusCell extends StatelessWidget {
  const _StatusCell({required this.label, required this.color});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 7),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      );
}
