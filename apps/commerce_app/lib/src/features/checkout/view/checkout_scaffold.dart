import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Checkout-only shell translated from Medusa's `(checkout)` layout.
final class CheckoutScaffold extends StatelessWidget {
  /// Creates the focused checkout shell.
  const CheckoutScaffold({required this.body, super.key});

  /// Checkout route content between its header and attribution.
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          leadingWidth: MediaQuery.sizeOf(context).width >= 1024 ? 240 : 96,
          leading: TextButton.icon(
            onPressed: () => context.navigator.cart().go(),
            icon: const Icon(Icons.chevron_left, size: 18),
            label: Text(
              MediaQuery.sizeOf(context).width >= 1024
                  ? context.tr(
                      'shop_checkout_back_cart',
                      defaultText: 'BACK TO SHOPPING CART',
                    )
                  : context.tr('shop_checkout_back', defaultText: 'BACK'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          title: TextButton(
            onPressed: () => context.navigator.catalog().go(),
            child: const TranslatedText(
              'shop_brand',
              defaultText: 'MORROW',
              style: TextStyle(
                fontSize: 18,
                height: 20 / 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        body: body,
      );
}
