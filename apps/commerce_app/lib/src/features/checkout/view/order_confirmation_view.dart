import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'order_payment_details.dart';
import 'order_receipt_details.dart';
import 'order_receipt_items.dart';

/// Full Medusa order-completed template rendered from a frozen receipt.
final class OrderConfirmationView extends StatelessWidget {
  /// Creates the completed order view.
  const OrderConfirmationView({required this.order, super.key});

  /// Frozen paid order shown as the receipt.
  final Order order;

  @override
  Widget build(BuildContext context) {
    final titleLines = context
        .tr(
          'shop_checkout_thank_you',
          defaultText: 'Thank you!\nYour order was placed successfully.',
        )
        .split('\n');

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 896),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final line in titleLines) ...[
                            Text(line, style: _orderCompleteTitleStyle),
                            if (line != titleLines.last)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(context.tr(
                        'shop_checkout_confirmation_sent',
                        defaultText:
                            'We have sent the order confirmation details to {email}.',
                        args: {'email': order.email},
                      )),
                      const SizedBox(height: 8),
                      Text(context.tr(
                        'shop_checkout_order_date',
                        defaultText: 'Order date: {date}',
                        args: {
                          'date': formatStoreDate(
                            MaterialLocalizations.of(context),
                            order.placedAt,
                          ),
                        },
                      )),
                      const SizedBox(height: 8),
                      Text(
                        context.tr(
                          'shop_checkout_order_number',
                          defaultText: 'Order number: {id}',
                          args: {'id': order.displayId},
                        ),
                        style: const TextStyle(color: StoreColors.interactive),
                      ),
                      const SizedBox(height: 16),
                      const TranslatedText(
                        'shop_checkout_summary',
                        defaultText: 'Summary',
                        style: TextStyle(fontSize: 32, height: 44 / 32),
                      ),
                      const SizedBox(height: 16),
                      OrderReceiptItems(order: order),
                      const SizedBox(height: 24),
                      OrderReceiptTotals(order: order),
                      const SizedBox(height: 40),
                      OrderShippingDetails(order: order),
                      const SizedBox(height: 40),
                      OrderPaymentDetails(order: order),
                      const SizedBox(height: 40),
                      CustomerServiceOrderHelp(
                        orderReference: '${order.displayId}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const StoreFooter(),
        ],
      ),
    );
  }
}

const _orderCompleteTitleStyle = TextStyle(
  fontSize: 30,
  height: 36 / 30,
  fontWeight: FontWeight.w600,
);
