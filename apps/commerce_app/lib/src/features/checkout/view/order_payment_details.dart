import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

const _orderPaymentHeadingStyle = TextStyle(
  fontSize: 32,
  height: 44 / 32,
);

/// Payment provider and final payment status.
final class OrderPaymentDetails extends StatelessWidget {
  /// Creates the payment detail block.
  const OrderPaymentDetails({required this.order, super.key});

  /// Frozen paid order.
  final Order order;

  @override
  Widget build(BuildContext context) {
    final payment = order.payment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TranslatedText(
          'shop_checkout_payment',
          defaultText: 'Payment',
          style: _orderPaymentHeadingStyle,
        ),
        const SizedBox(height: 24),
        if (payment != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PaymentDetail(
                  title: context.tr(
                    'shop_checkout_payment_method',
                    defaultText: 'Payment method',
                  ),
                  child: Text(_providerTitle(context, payment.providerId)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: _PaymentDetail(
                  title: context.tr(
                    'shop_checkout_payment_details',
                    defaultText: 'Payment details',
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: StoreColors.subtleHover,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.credit_card, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(context.tr(
                          'shop_checkout_paid_at',
                          defaultText: '{amount} paid at {date}',
                          args: {
                            'amount': formatMoney(payment.amount),
                            'date': _paymentDate(context, payment.createdAt),
                          },
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 32),
        const Divider(),
      ],
    );
  }

  String _providerTitle(BuildContext context, String providerId) =>
      providerId == 'manual'
          ? context.tr(
              'shop_checkout_manual_payment',
              defaultText: 'Manual Payment',
            )
          : providerId;

  String _paymentDate(BuildContext context, DateTime value) {
    return formatStoreDateTime(MaterialLocalizations.of(context), value);
  }
}

final class _PaymentDetail extends StatelessWidget {
  const _PaymentDetail({required this.title, required this.child});

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          DefaultTextStyle.merge(
            style: const TextStyle(color: StoreColors.foregroundSubtle),
            child: child,
          ),
        ],
      );
}
