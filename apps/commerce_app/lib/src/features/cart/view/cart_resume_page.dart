import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Medusa-compatible public cart handoff route.
@AppRoute('/cart/resume/:cartId', name: 'cartResume', guards: [])
final class CartResumePage extends StatefulWidget {
  /// Creates the cart handoff route.
  const CartResumePage({required this.cartId, super.key});

  /// Opaque cart capability supplied by an external checkout handoff.
  final String cartId;

  @override
  State<CartResumePage> createState() => _CartResumePageState();
}

final class _CartResumePageState extends State<CartResumePage> {
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    unawaited(_resume());
  }

  Future<void> _resume() async {
    final restored =
        await context.readCartViewModel().restoreCapability(widget.cartId);
    if (!mounted) return;
    if (restored) {
      context.navigator.checkout().replace();
    } else {
      setState(() => _expired = true);
    }
  }

  @override
  Widget build(BuildContext context) => StoreScaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _expired
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr(
                          'shop_cart_resume_expired',
                          defaultText: 'This cart link has expired.',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.navigator.catalog().go(),
                        child: const TranslatedText(
                          'shop_explore_products',
                          defaultText: 'Explore products',
                        ),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      );
}
