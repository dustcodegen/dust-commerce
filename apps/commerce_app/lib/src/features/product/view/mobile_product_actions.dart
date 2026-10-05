import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'mobile_product_options_dialog.dart';

/// Fixed purchase controls translated from Medusa DTC MobileActions.
class MobileProductActions extends StatelessWidget {
  /// Creates the sticky mobile purchase surface.
  const MobileProductActions({required this.state, super.key});

  /// Product and selection currently visible on the route.
  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final product = state.product!;
    final hasOptions = product.variants.length > 1;
    return Material(
      color: StoreColors.base,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: StoreColors.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: TranslatedText(
                      'shop_price_separator',
                      defaultText: '—',
                    ),
                  ),
                  ProductPrice(state: state, compact: true),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (hasOptions) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => showMobileProductOptions(context),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _optionLabel(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(child: ProductPurchaseButton(state: state)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _optionLabel(BuildContext context) {
    final product = state.product!;
    final values = [
      for (final option in product.options) state.selection[option.id],
    ].whereType<String>().toList(growable: false);
    return values.length == product.options.length
        ? values.join(' / ')
        : context.tr('shop_select_options', defaultText: 'Select options');
  }
}
