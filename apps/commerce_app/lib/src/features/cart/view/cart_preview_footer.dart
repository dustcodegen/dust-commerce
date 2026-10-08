import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source footer for the desktop cart preview.
class CartPreviewFooter extends StatelessWidget {
  /// Creates the subtotal and cart action footer.
  const CartPreviewFooter({
    required this.subtotal,
    required this.onClose,
    super.key,
  });

  /// Closes the cart preview before route navigation.
  final VoidCallback onClose;

  /// Server-owned cart subtotal.
  final Money subtotal;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr(
                    'shop_cart_preview_subtotal',
                    defaultText: 'Subtotal (excl. taxes)',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 20 / 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatMoney(subtotal),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  onClose();
                  context.navigator.cart().go();
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const TranslatedText(
                  'shop_cart_go_to_cart',
                  defaultText: 'Go to cart',
                ),
              ),
            ),
          ],
        ),
      );
}
