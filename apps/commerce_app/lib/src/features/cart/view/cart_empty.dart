import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// EmptyCartMessage translated from the Medusa DTC source.
class CartEmpty extends StatelessWidget {
  /// Creates the empty state.
  const CartEmpty({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 192,
                  ),
                  child: _CartEmptyContent(),
                ),
              ),
            ),
            const StoreFooter(),
          ],
        ),
      );
}

class _CartEmptyContent extends StatelessWidget {
  const _CartEmptyContent();

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 512),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TranslatedText(
                'shop_cart_title',
                defaultText: 'Cart',
                style: TextStyle(fontSize: 32, height: 44 / 32),
              ),
              const SizedBox(height: 16),
              const TranslatedText(
                'shop_cart_empty_body',
                defaultText: "You don't have anything in your cart. Let's "
                    'change that, use the link below to start browsing our '
                    'products.',
                style: TextStyle(fontSize: 14, height: 24 / 14),
              ),
              const SizedBox(height: 24),
              StoreInteractiveLink(
                onPressed: () => context.navigator.catalog().go(),
                child: const TranslatedText(
                  'shop_explore_products',
                  defaultText: 'Explore products',
                ),
              ),
            ],
          ),
        ),
      );
}
