import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Shows the selected Medusa product variant's current availability.
class ProductAvailability extends StatelessWidget {
  /// Creates an availability label for [state].
  const ProductAvailability({required this.state, super.key});

  /// Product and option selection currently visible on the route.
  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final variant = state.selectedVariant;
    if (variant == null) return const SizedBox.shrink();

    return Text(
      variant.isInStock
          ? context.tr('shop_in_stock', defaultText: 'In stock')
          : context.tr('shop_out_of_stock', defaultText: 'Out of stock'),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: StoreColors.foregroundSubtle,
          ),
    );
  }
}
