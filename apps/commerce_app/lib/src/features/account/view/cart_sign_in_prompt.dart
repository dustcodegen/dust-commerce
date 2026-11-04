import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Medusa cart prompt shown only when no customer session is active.
class CartSignInPrompt extends StatelessWidget {
  /// Creates the prompt.
  const CartSignInPrompt({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TranslatedText(
                  'shop_cart_account_prompt',
                  defaultText: 'Already have an account?',
                  style: TextStyle(
                    fontSize: 18,
                    height: 28.8 / 18,
                  ),
                ),
                const SizedBox(height: 8),
                const TranslatedText(
                  'shop_cart_account_prompt_body',
                  defaultText: 'Sign in for a better experience.',
                  style: TextStyle(
                    color: StoreColors.foregroundSubtle,
                    fontSize: 16,
                    height: 24 / 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () => context.navigator.account().go(),
            child: const TranslatedText(
              'shop_account_sign_in',
              defaultText: 'Sign in',
            ),
          ),
        ],
      );
}
