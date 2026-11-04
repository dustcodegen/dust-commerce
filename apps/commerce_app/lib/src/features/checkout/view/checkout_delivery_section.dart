import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_delivery_content.dart';
import 'checkout_step_header.dart';

/// Server-priced delivery choice translated from Medusa Shipping.
final class CheckoutDeliverySection extends StatelessWidget {
  /// Creates the delivery step.
  const CheckoutDeliverySection({
    required this.open,
    required this.state,
    required this.cart,
    super.key,
  });

  /// Current server-authoritative cart and shipping choices.
  final CartState cart;

  /// Whether delivery choices are expanded.
  final bool open;

  /// Checkout operation state.
  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final selected = cart.cart?.cart.shippingMethod;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckoutStepHeader(
          title: context.tr('shop_checkout_delivery', defaultText: 'Delivery'),
          open: open,
          complete: selected != null,
          onEdit: () => context.pushCheckoutStep('delivery'),
        ),
        if (open)
          CheckoutDeliveryChoices(
            cart: cart,
            selected: selected,
            state: state,
          )
        else
          CheckoutDeliverySummary(selected: selected),
        const CheckoutSectionDivider(),
      ],
    );
  }
}
