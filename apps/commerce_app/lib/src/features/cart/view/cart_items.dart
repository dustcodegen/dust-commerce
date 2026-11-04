import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'cart_line_item.dart';

/// ItemsTemplate translated from the source cart table.
class CartItems extends StatelessWidget {
  /// Creates the cart item list.
  const CartItems({required this.view, required this.state, super.key});

  /// Server cart and totals.
  final CartView view;

  /// Current mutation state.
  final CartState state;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: TranslatedText(
              'shop_cart_title',
              defaultText: 'Cart',
              style: TextStyle(
                fontSize: 32,
                height: 44 / 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = MediaQuery.sizeOf(context).width >= 1024;
              return Column(
                children: [
                  _CartHeader(wide: wide),
                  for (final (index, item) in view.cart.items.reversed.indexed)
                    CartLineItem(
                      item: item,
                      state: state,
                      wide: wide,
                      showDivider: index < view.cart.items.length - 1,
                    ),
                ],
              );
            },
          ),
        ],
      );
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: StoreColors.foregroundSubtle,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: StoreColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: wide ? 104 : 64,
            child: Text(
              context.tr('shop_cart_item', defaultText: 'Item'),
              style: style,
            ),
          ),
          const Expanded(child: SizedBox.shrink()),
          SizedBox(
            width: wide ? 168 : 112,
            child: Text(
              context.tr('shop_cart_quantity', defaultText: 'Quantity'),
              style: style,
            ),
          ),
          if (wide)
            SizedBox(
              width: 80,
              child: Text(
                context.tr('shop_cart_price', defaultText: 'Price'),
                style: style,
              ),
            ),
          SizedBox(
            width: 88,
            child: Text(
              context.tr('shop_cart_total', defaultText: 'Total'),
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
