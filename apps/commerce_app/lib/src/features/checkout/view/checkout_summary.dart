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
          for (var index = 0; index < view.cart.items.length; index += 1)
            _CheckoutLine(
              item: view.cart.items[index],
              showDivider: index < view.cart.items.length - 1,
            ),
          const SizedBox(height: 24),
          PromotionCode(cart: view.cart, state: state),
        ],
      );
}

final class _CheckoutLine extends StatelessWidget {
  const _CheckoutLine({required this.item, required this.showDivider});

  final LineItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
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
                        style: const TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.variantTitle case final title?)
                        Text(
                          context.tr(
                            'shop_cart_variant',
                            defaultText: 'Variant: {name}',
                            args: {'name': title},
                          ),
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
          ),
          if (showDivider) const Divider(),
        ],
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
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          CheckoutTotalRow(
            label: context.tr(
              'shop_checkout_total',
              defaultText: 'Total',
            ),
            money: view.total,
            strong: true,
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 16),
          const Divider(),
        ],
      );
}
