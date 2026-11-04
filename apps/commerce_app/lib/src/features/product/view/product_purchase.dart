import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Price label matching Medusa's selected-variant and cheapest-price behavior.
class ProductPrice extends StatelessWidget {
  /// Creates a product price for [state].
  const ProductPrice({required this.state, this.compact = false, super.key});

  /// Uses the sticky-mobile text scale when true.
  final bool compact;

  /// Product and current variant selection.
  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final product = state.product!;
    final selected = state.selectedVariant;
    final price = selected?.priceIn(state.currencyCode) ??
        product.cheapestIn(state.currencyCode);
    final original = selected?.originalPriceIn(state.currencyCode) ??
        product.cheapestOriginalIn(state.currencyCode);
    final salePercent = selected?.salePercentageDiffIn(state.currencyCode) ??
        product
            .cheapestVariantIn(state.currencyCode)
            ?.salePercentageDiffIn(state.currencyCode);
    final prefix = selected == null
        ? context.tr('shop_from_price', defaultText: 'From ')
        : '';
    final label = price == null ? '-' : '$prefix${formatMoney(price)}';
    final style = compact
        ? Theme.of(context).textTheme.bodyLarge
        : Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            );
    final sale = price != null && original != null && original > price;
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (sale) ...[
            Text(
              formatMoney(original),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            price == null ? '-' : formatMoney(price),
            style: style?.copyWith(
              color: sale ? StoreColors.interactive : null,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: style?.copyWith(
            color: sale ? StoreColors.interactive : null,
          ),
        ),
        if (sale) ...[
          const SizedBox(height: 4),
          Text(
            'Original: ${formatMoney(original)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: StoreColors.foregroundSubtle,
                  decoration: TextDecoration.lineThrough,
                ),
          ),
          if (salePercent != null)
            Text(
              '-$salePercent%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: StoreColors.interactive,
                  ),
            ),
        ],
      ],
    );
  }
}

/// Real add-to-cart action shared by inline and sticky-mobile controls.
class ProductPurchaseButton extends StatelessWidget {
  /// Creates an add-to-cart button for [state].
  const ProductPurchaseButton({required this.state, super.key});

  /// Product and current variant selection.
  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedVariant;
    final cart = context.watchCartViewModel().value;
    final busy = cart.status == CartStatus.loading;
    return FilledButton(
      onPressed: selected == null || !selected.isInStock || busy
          ? null
          : () => _add(context, selected),
      child: busy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              selected == null
                  ? context.tr(
                      'shop_select_variant',
                      defaultText: 'Select variant',
                    )
                  : selected.isInStock
                      ? context.tr(
                          'shop_add_to_cart',
                          defaultText: 'Add to cart',
                        )
                      : context.tr(
                          'shop_out_of_stock',
                          defaultText: 'Out of stock',
                        ),
            ),
    );
  }

  Future<void> _add(BuildContext context, ProductVariant variant) async {
    final added = await context.readCartViewModel().add(variant);
    if (added || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            'shop_add_to_cart_failed',
            defaultText: 'Could not add to cart',
          ),
        ),
      ),
    );
  }
}
