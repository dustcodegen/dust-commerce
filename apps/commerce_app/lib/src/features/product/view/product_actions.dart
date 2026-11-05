import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// Variant controls translated from Medusa DTC ProductActions.
class ProductActions extends StatelessWidget {
  /// Creates controls for the loaded product [state].
  const ProductActions({required this.state, super.key});

  /// Product and option selection currently visible on the detail route.
  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final cart = context.watchCartViewModel().value;
    final busy = cart.status == CartStatus.loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductOptionGroups(state: state, disabled: busy),
        if (state.product!.variants.length > 1) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
        ] else
          const SizedBox(height: 8),
        ProductPrice(state: state),
        const SizedBox(height: 8),
        ProductAvailability(state: state),
        const SizedBox(height: 8),
        ProductPurchaseButton(state: state),
      ],
    );
  }
}
