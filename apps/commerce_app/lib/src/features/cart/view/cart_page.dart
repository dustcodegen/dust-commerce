import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'cart_empty.dart';
import 'cart_layout.dart';

/// Medusa DTC cart route backed by the shared server cart.
@AppRoute('/cart', name: 'cart', guards: [])
class CartPage extends StatelessWidget {
  /// Creates the cart page.
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watchCartViewModel().value;
    final view = state.cart;
    return StoreScaffold(
      body: view == null
          ? switch (state.status) {
              CartStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
              CartStatus.failed => _CartLoadFailure(
                  message: state.message ??
                      context.tr(
                        'shop_cart_load_failed',
                        defaultText: 'Could not load your cart.',
                      ),
                ),
              CartStatus.idle || CartStatus.ready => const CartEmpty(),
            }
          : view.cart.isEmpty
              ? const CartEmpty()
              : CartLayout(view: view, state: state),
    );
  }
}

class _CartLoadFailure extends StatelessWidget {
  const _CartLoadFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: context.readCartViewModel().restore,
                child: const TranslatedText(
                  'shop_retry',
                  defaultText: 'Try again',
                ),
              ),
            ],
          ),
        ),
      );
}
