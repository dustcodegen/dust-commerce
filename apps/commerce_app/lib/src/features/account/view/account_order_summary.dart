import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Account order total block translated from Medusa's OrderSummary component.
final class AccountOrderSummary extends StatelessWidget {
  /// Creates the immutable account order summary.
  const AccountOrderSummary({required this.order, super.key});

  /// Frozen customer-owned order.
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TranslatedText(
            'shop_account_order_summary',
            defaultText: 'Order Summary',
            style: TextStyle(
              fontSize: 14,
              height: 24 / 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _AccountOrderSummaryRow(
            label: context.tr(
              'shop_checkout_subtotal',
              defaultText: 'Subtotal',
            ),
            value: order.subtotal,
            prominent: true,
          ),
          if (!order.discountTotal.isZero)
            _AccountOrderSummaryRow(
              label: context.tr(
                'shop_checkout_discount',
                defaultText: 'Discount',
              ),
              value: order.discountTotal,
              discount: true,
            ),
          _AccountOrderSummaryRow(
            label: context.tr(
              'shop_checkout_shipping',
              defaultText: 'Shipping',
            ),
            value: order.shippingTotal,
          ),
          _AccountOrderSummaryRow(
            label: context.tr(
              'shop_checkout_taxes',
              defaultText: 'Taxes',
            ),
            value: order.tax,
          ),
          const SizedBox(height: 16),
          const _DashedAccountOrderSummaryDivider(),
          const SizedBox(height: 16),
          _AccountOrderSummaryRow(
            label: context.tr(
              'shop_checkout_total',
              defaultText: 'Total',
            ),
            value: order.total,
            prominent: true,
          ),
        ],
      );
}

final class _AccountOrderSummaryRow extends StatelessWidget {
  const _AccountOrderSummaryRow({
    required this.label,
    required this.value,
    this.discount = false,
    this.prominent = false,
  });

  final bool discount;

  final String label;

  final bool prominent;

  final Money value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: prominent ? 8 : 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _style),
            Text('${discount ? '- ' : ''}${formatMoney(value)}', style: _style),
          ],
        ),
      );

  TextStyle get _style => TextStyle(
        fontSize: prominent ? 14 : 12,
        height: prominent ? 24 / 14 : 20 / 12,
      );
}

final class _DashedAccountOrderSummaryDivider extends StatelessWidget {
  const _DashedAccountOrderSummaryDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 1,
        child: CustomPaint(
          painter: _DashedAccountOrderSummaryPainter(),
          size: Size.infinite,
        ),
      );
}

final class _DashedAccountOrderSummaryPainter extends CustomPainter {
  const _DashedAccountOrderSummaryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = StoreColors.border
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
