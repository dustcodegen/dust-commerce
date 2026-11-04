part of 'admin_order_detail_page.dart';

/// Responsive two-column composition matching Medusa's order-detail source.
final class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order, required this.onBack});

  final VoidCallback onBack;
  final AdminOrderDetail order;

  @override
  Widget build(BuildContext context) {
    final main = Column(children: [
      AdminOrderGeneralSection(order: order),
      const SizedBox(height: 12),
      AdminOrderSummarySection(order: order),
      const SizedBox(height: 12),
      AdminOrderPaymentSection(order: order),
      const SizedBox(height: 12),
      AdminOrderFulfillmentSection(order: order),
    ]);
    final side = Column(children: [
      AdminOrderCustomerSection(order: order),
      const SizedBox(height: 12),
      AdminOrderActivitySection(order: order),
    ]);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Orders'),
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) => constraints.maxWidth >= 900
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: main),
                            const SizedBox(width: 12),
                            Expanded(flex: 3, child: side),
                          ],
                        )
                      : Column(children: [
                          main,
                          const SizedBox(height: 12),
                          side,
                        ]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
