import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

import 'cart_items.dart';
import 'cart_summary.dart';

/// Responsive CartTemplate grid from the source storefront.
class CartLayout extends StatelessWidget {
  /// Creates a populated cart layout.
  const CartLayout({required this.view, required this.state, super.key});

  /// Server cart and authoritative totals.
  final CartView view;

  /// Mutation progress visible to line controls.
  final CartState state;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 48,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = MediaQuery.sizeOf(context).width >= 1024;
                      final account = context.watchAccountViewModel().value;
                      final items = _CartColumn(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!account.isAuthenticated) ...[
                              const CartSignInPrompt(),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 24),
                            ],
                            CartItems(view: view, state: state),
                          ],
                        ),
                      );
                      final summary = _CartColumn(
                        child: CartSummary(view: view, state: state),
                      );
                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [items, summary],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: items),
                          const SizedBox(width: 160),
                          SizedBox(width: 360, child: summary),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const StoreFooter(),
          ],
        ),
      );
}

class _CartColumn extends StatelessWidget {
  const _CartColumn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: child,
      );
}
