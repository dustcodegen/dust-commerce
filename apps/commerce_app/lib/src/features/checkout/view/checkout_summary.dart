import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import '../../cart/view/promotion_code.dart';
import 'checkout_total_row.dart';

/// Sticky desktop checkout summary translated from Medusa CheckoutSummary.
final class CheckoutSummary extends StatelessWidget {
  /// Creates a checkout summary from authoritative cart totals.
  const CheckoutSummary({required this.view, required this.state, super.key});

  /// Mutation state used by the promotion control.
  final CartState state;

  /// Authoritative cart totals and lines.
  final CartView view;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TranslatedText(
            'shop_checkout_in_cart',
            defaultText: 'In your Cart',
            style: TextStyle(
              fontSize: 32,
              height: 44 / 32,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          _CheckoutTotals(view: view),
          for (final item in view.cart.items) _CheckoutLine(item: item),
          const SizedBox(height: 24),
          PromotionCode(cart: view.cart, state: state),
        ],
      );
}

final class _CheckoutLine extends StatelessWidget {
  const _CheckoutLine({required this.item});

  final LineItem item;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 64,
              child: ProductImage(url: item.thumbnail, aspectRatio: 1),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      '${item.quantity}x ',
                      style: const TextStyle(
                        color: StoreColors.foregroundMuted,
                      ),
                    ),
                    Text(formatMoney(item.unitPrice)),
                  ],
                ),
                Text(formatMoney(item.subtotal)),
              ],
            ),
          ],
        ),
      );
}

final class _CheckoutTotals extends StatelessWidget {
  const _CheckoutTotals({required this.view});

  final CartView view;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          CheckoutTotalRow(
            label: context.tr(
              'shop_checkout_subtotal',
              defaultText: 'Subtotal',
            ),
            money: view.subtotal,
          ),
          CheckoutTotalRow(
            label: context.tr(
              'shop_checkout_shipping',
              defaultText: 'Shipping',
            ),
            money: view.shippingTotal,
          ),
          if (!view.discountTotal.isZero)
            CheckoutTotalRow(
              label: context.tr(
                'shop_checkout_discount',
                defaultText: 'Discount',
              ),
              money: view.discountTotal,
              discount: true,
            ),
          CheckoutTotalRow(
            label: context.tr(
              'shop_checkout_taxes',
              defaultText: 'Taxes',
            ),
            money: view.tax,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          CheckoutTotalRow(
            label: context.tr(
              'shop_checkout_total',
              defaultText: 'Total',
            ),
            money: view.total,
            strong: true,
          ),
          const SizedBox(height: 16),
          const Divider(),
        ],
      );
}
