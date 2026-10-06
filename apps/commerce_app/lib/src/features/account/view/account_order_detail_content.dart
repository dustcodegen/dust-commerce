import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import '../../checkout/view/order_receipt_details.dart';
import '../../checkout/view/order_receipt_items.dart';
import 'account_order_summary.dart';

const _orderDetailTitleStyle = TextStyle(
  fontSize: 30,
  height: 48 / 30,
  fontWeight: FontWeight.w600,
);

/// Medusa order-detail template rendered from immutable order snapshots.
final class AccountOrderDetailContent extends StatelessWidget {
  /// Creates the detail content for [order].
  const AccountOrderDetailContent({required this.order, super.key});

  /// Frozen customer-owned order.
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: TranslatedText(
                  'shop_account_order_details',
                  defaultText: 'Order details',
                  style: _orderDetailTitleStyle,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.navigator.accountOrders().go(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: StoreColors.foregroundSubtle,
                  textStyle: const TextStyle(fontSize: 14, height: 24 / 14),
                ),
                icon: const Icon(Icons.close, size: 16),
                label: const TranslatedText(
                  'shop_account_back_overview',
                  defaultText: 'Back to overview',
                ),
              ),
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
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _OrderStatusText(
                title: context.tr(
                  'shop_account_order_status',
                  defaultText: 'Order status',
                ),
                value: _fulfillmentStatus(context),
              ),
              _OrderStatusText(
                title: context.tr(
                  'shop_account_payment_status',
                  defaultText: 'Payment status',
                ),
                value: _paymentStatus(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          OrderReceiptItems(order: order),
          const SizedBox(height: 32),
          OrderShippingDetails(order: order),
          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 32),
          AccountOrderSummary(order: order),
          OrderReturnSection(order: order),
          const SizedBox(height: 32),
          CustomerServiceOrderHelp(orderReference: '${order.displayId}'),
        ],
      );

  String _fulfillmentStatus(BuildContext context) =>
      switch (order.fulfillmentStatus) {
        OrderFulfillmentStatus.notFulfilled => context.tr(
            'shop_account_fulfillment_not_fulfilled',
            defaultText: 'Not fulfilled',
          ),
        OrderFulfillmentStatus.partiallyFulfilled => context.tr(
            'shop_account_fulfillment_partially_fulfilled',
            defaultText: 'Partially fulfilled',
          ),
        OrderFulfillmentStatus.fulfilled => context.tr(
            'shop_account_fulfillment_fulfilled',
            defaultText: 'Fulfilled',
          ),
        OrderFulfillmentStatus.partiallyShipped => context.tr(
            'shop_account_fulfillment_partially_shipped',
            defaultText: 'Partially shipped',
          ),
        OrderFulfillmentStatus.shipped => context.tr(
            'shop_account_fulfillment_shipped',
            defaultText: 'Shipped',
          ),
        OrderFulfillmentStatus.partiallyDelivered => context.tr(
            'shop_account_fulfillment_partially_delivered',
            defaultText: 'Partially delivered',
          ),
        OrderFulfillmentStatus.delivered => context.tr(
            'shop_account_fulfillment_delivered',
            defaultText: 'Delivered',
          ),
        OrderFulfillmentStatus.canceled => context.tr(
            'shop_account_fulfillment_canceled',
            defaultText: 'Canceled',
          ),
      };

  String _paymentStatus(BuildContext context) => switch (order.paymentStatus) {
        PaymentStatus.awaiting => context.tr(
            'shop_account_payment_awaiting',
            defaultText: 'Awaiting',
          ),
        PaymentStatus.captured => context.tr(
            'shop_account_payment_captured',
            defaultText: 'Captured',
          ),
        PaymentStatus.refunded => context.tr(
            'shop_account_payment_refunded',
            defaultText: 'Refunded',
          ),
      };
}

final class _OrderStatusText extends StatelessWidget {
  const _OrderStatusText({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(children: [
          TextSpan(text: '$title: '),
          TextSpan(
            text: value,
            style: const TextStyle(color: StoreColors.foregroundSubtle),
          ),
        ]),
      );
}
