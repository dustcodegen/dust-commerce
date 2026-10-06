import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'order_delivery_detail.dart';

const _orderDeliveryHeadingStyle = TextStyle(
  fontSize: 32,
  height: 44 / 32,
);

/// Shipping address, contact, and delivery method from the frozen order.
final class OrderShippingDetails extends StatelessWidget {
  /// Creates the shipping detail block.
  const OrderShippingDetails({required this.order, super.key});

  /// Frozen paid order.
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TranslatedText(
            'shop_checkout_delivery',
            defaultText: 'Delivery',
            style: _orderDeliveryHeadingStyle,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 32,
            runSpacing: 24,
            children: [
              OrderDeliveryDetail(
                title: context.tr(
                  'shop_checkout_shipping_address',
                  defaultText: 'Shipping Address',
                ),
                lines: [
                  order.shippingAddress.fullName,
                  order.shippingAddress.line1,
                  if (order.shippingAddress.line2 case final line?) line,
                  '${order.shippingAddress.postalCode}, ${order.shippingAddress.city}',
                  order.shippingAddress.countryCode.toUpperCase(),
                ],
              ),
              OrderDeliveryDetail(
                title: context.tr(
                  'shop_checkout_contact',
                  defaultText: 'Contact',
                ),
                lines: [
                  if (order.shippingAddress.phone case final phone?) phone,
                  order.email,
                ],
              ),
              OrderDeliveryDetail(
                title: context.tr(
                  'shop_checkout_method',
                  defaultText: 'Method',
                ),
                lines: [
                  if (order.shippingMethod case final method?)
                    '${method.name} (${formatMoney(method.amount)})'
                  else
                    context.tr(
                      'shop_checkout_delivery',
                      defaultText: 'Delivery',
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
        ],
      );
}
