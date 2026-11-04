import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:flutter/material.dart';

import 'checkout_attribution.dart';

/// Checkout-route 404 content rendered inside the focused checkout shell.
final class CheckoutNotFound extends StatelessWidget {
  /// Creates the source-shaped checkout boundary.
  const CheckoutNotFound({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: (MediaQuery.sizeOf(context).height - 64)
                  .clamp(0, double.infinity)
                  .toDouble(),
              child: Center(
                child: StoreNotFoundMessage(
                  onFrontpage: () => context.navigator.catalog().go(),
                ),
              ),
            ),
            const CheckoutAttribution(),
          ],
        ),
      );
}
