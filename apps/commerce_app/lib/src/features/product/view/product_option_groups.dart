import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Medusa option axes shared by inline and sticky-mobile purchase controls.
class ProductOptionGroups extends StatelessWidget {
  /// Creates option groups for the current product [state].
  const ProductOptionGroups({
    required this.state,
    this.disabled = false,
    this.axisSpacing = 16,
    super.key,
  });

  /// Space between option axes.
  final double axisSpacing;

  /// Whether an add-to-cart request temporarily blocks option changes.
  final bool disabled;

  /// Current product and option selection.
  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final product = state.product!;
    if (product.variants.length <= 1) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in product.options) ...[
          Text(
            context.tr(
              'shop_select_option',
              defaultText: 'Select {name}',
              args: {'name': option.title},
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  constraints.maxWidth.isFinite ? constraints.maxWidth : 300.0;
              final rawColumns = ((width + 8) / 72).floor();
              final columns = rawColumns < 1
                  ? 1
                  : rawColumns > option.values.length
                      ? option.values.length
                      : rawColumns;
              if (columns == 0) return const SizedBox.shrink();
              final itemWidth = (width - ((columns - 1) * 8)) / columns;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in option.values)
                    SizedBox(
                      width: itemWidth,
                      child: ProductOptionButton(
                        label: value,
                        selected: state.selection[option.id] == value,
                        onPressed:
                            disabled || !state.canSelect(option.id, value)
                                ? null
                                : () => _select(
                                      context,
                                      product.handle,
                                      option.id,
                                      value,
                                    ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (option.id != product.options.last.id)
            SizedBox(height: axisSpacing),
        ],
      ],
    );
  }

  void _select(
    BuildContext context,
    String handle,
    String optionId,
    String value,
  ) {
    final viewModel = context.readProductViewModel()..select(optionId, value);
    final variantId = viewModel.state.selectedVariant?.id;
    if (context.productVariantId != variantId) {
      context.replaceProductVariant(handle, variantId);
    }
  }
}
