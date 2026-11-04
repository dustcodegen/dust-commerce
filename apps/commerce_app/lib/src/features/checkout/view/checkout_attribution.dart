import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Checkout footer attribution translated from MedusaCTA.
final class CheckoutAttribution extends StatelessWidget {
  /// Creates the checkout attribution.
  const CheckoutAttribution({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: TranslatedText(
          'shop_hero_subtitle',
          defaultText: 'Powered by dust',
          style: TextStyle(
            color: StoreColors.foregroundMuted,
            fontSize: 12,
          ),
        ),
      );
}
