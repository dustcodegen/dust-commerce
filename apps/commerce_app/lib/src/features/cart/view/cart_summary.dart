import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'promotion_code.dart';

/// Summary and CartTotals translated from the source storefront.
class CartSummary extends StatelessWidget {
  /// Creates the summary.
  const CartSummary({required this.view, required this.state, super.key});

  /// Server cart and totals.
  final CartView view;

  /// Current mutation state.
  final CartState state;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TranslatedText(
            'shop_cart_summary',
            defaultText: 'Summary',
            style: TextStyle(
              fontSize: 32,
              height: 44 / 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          PromotionCode(cart: view.cart, state: state),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _TotalRow(
            label: context.tr(
              'shop_cart_subtotal_excl',
              defaultText: 'Subtotal (excl. shipping and taxes)',
            ),
            value: view.subtotal,
          ),
          _TotalRow(
            label: context.tr('shop_cart_shipping', defaultText: 'Shipping'),
            value: view.shippingTotal,
          ),
          if (!view.discountTotal.isZero)
            _TotalRow(
              label: context.tr('shop_cart_discount', defaultText: 'Discount'),
              value: view.discountTotal,
              discount: true,
            ),
          _TotalRow(
            label: context.tr('shop_cart_taxes', defaultText: 'Taxes'),
            value: view.tax,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TranslatedText(
                'shop_cart_total',
                defaultText: 'Total',
                style: TextStyle(
                  color: StoreColors.foreground,
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
              Text(
                formatMoney(view.total),
                style: const TextStyle(
                  fontSize: 20,
                  height: 28 / 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.status == CartStatus.loading
                ? null
                : () => context.pushCheckoutStep(checkoutEntryStep(view.cart)),
            child: const TranslatedText(
              'shop_cart_checkout',
              defaultText: 'Go to checkout',
            ),
          ),
        ],
      );
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.discount = false,
  });

  final bool discount;
  final String label;
  final Money value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: StoreColors.foregroundSubtle,
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${discount ? '- ' : ''}${formatMoney(value)}',
              style: TextStyle(
                color: discount
                    ? StoreColors.interactive
                    : StoreColors.foregroundSubtle,
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
          ],
        ),
      );
}
