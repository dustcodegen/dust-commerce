import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'order_receipt_total_row.dart';

/// Immutable line snapshots shown on the confirmation receipt.
final class OrderReceiptItems extends StatelessWidget {
  /// Creates the order line list.
  const OrderReceiptItems({required this.order, super.key});

  /// Frozen paid order.
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Divider(height: 1),
          for (final item in order.items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.square(
                    dimension: 64,
                    child: ProductImage(url: item.thumbnail, aspectRatio: 1),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (item.variantTitle case final title?)
                          Text(
                            title,
                            style: const TextStyle(
                              color: StoreColors.foregroundSubtle,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.quantity}x ${formatMoney(item.unitPrice)}',
                        style: const TextStyle(
                          color: StoreColors.foregroundMuted,
                        ),
                      ),
                      Text(formatMoney(item.subtotal)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      );
}

/// Frozen order totals; never recalculated from current catalogue data.
final class OrderReceiptTotals extends StatelessWidget {
  /// Creates receipt totals.
  const OrderReceiptTotals({required this.order, super.key});

  /// Frozen paid order.
  final Order order;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          OrderReceiptTotalRow(
            label: context.tr(
              'shop_cart_subtotal_excl',
              defaultText: 'Subtotal (excl. shipping and taxes)',
            ),
            value: order.subtotal,
          ),
          OrderReceiptTotalRow(
            label: context.tr(
              'shop_checkout_shipping',
              defaultText: 'Shipping',
            ),
            value: order.shippingTotal,
          ),
          if (!order.discountTotal.isZero)
            OrderReceiptTotalRow(
              label: context.tr(
                'shop_checkout_discount',
                defaultText: 'Discount',
              ),
              value: order.discountTotal,
              discount: true,
            ),
          OrderReceiptTotalRow(
            label: context.tr(
              'shop_checkout_taxes',
              defaultText: 'Taxes',
            ),
            value: order.tax,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          OrderReceiptTotalRow(
            label: context.tr(
              'shop_checkout_total',
              defaultText: 'Total',
            ),
            value: order.total,
            strong: true,
          ),
          const SizedBox(height: 16),
          const Divider(),
        ],
      );
}
