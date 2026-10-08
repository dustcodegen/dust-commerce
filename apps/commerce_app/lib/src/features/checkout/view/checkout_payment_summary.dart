import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Collapsed payment method and next-step details.
final class CheckoutPaymentSummary extends StatelessWidget {
  /// Creates a payment summary.
  const CheckoutPaymentSummary({required this.state, super.key});

  /// Retained payment method.
  final CheckoutState state;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _PaymentSummaryColumn(
              title: context.tr(
                'shop_checkout_payment_method',
                defaultText: 'Payment method',
              ),
              child: state.paymentMethod.match(
                some: (id) => PaymentProviderTitle(id: id),
                none: () => const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _PaymentSummaryColumn(
              title: context.tr(
                'shop_checkout_payment_details',
                defaultText: 'Payment details',
              ),
              child: const Row(
                children: [
                  SizedBox(
                    height: 28,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: StoreColors.subtleHover,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Center(child: Icon(Icons.credit_card, size: 16)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: TranslatedText(
                      'shop_checkout_payment_next_step',
                      defaultText: 'Another step will appear',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      );
}

/// Customer-facing provider title shared by choices and summary.
final class PaymentProviderTitle extends StatelessWidget {
  /// Creates a provider title.
  const PaymentProviderTitle({required this.id, super.key});

  /// Provider identifier from the server.
  final String id;

  /// Resolves a provider identifier to its localized customer-facing title.
  static String label(BuildContext context, String id) => id == 'manual'
      ? context.tr(
          'shop_checkout_manual_payment',
          defaultText: 'Manual Payment',
        )
      : id;

  @override
  Widget build(BuildContext context) => Text(label(context, id));
}

final class _PaymentSummaryColumn extends StatelessWidget {
  const _PaymentSummaryColumn({required this.title, required this.child});

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _paymentSummaryTitleStyle),
          const SizedBox(height: 4),
          DefaultTextStyle.merge(
            style: _paymentSummaryValueStyle,
            child: child,
          ),
        ],
      );
}

const _paymentSummaryTitleStyle = TextStyle(
  fontSize: 14,
  height: 20 / 14,
  fontWeight: FontWeight.w600,
);

const _paymentSummaryValueStyle = TextStyle(
  color: StoreColors.foregroundSubtle,
  fontSize: 14,
  height: 20 / 14,
);
