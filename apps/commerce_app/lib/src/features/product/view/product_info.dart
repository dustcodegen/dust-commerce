import 'package:commerce_app/route.dart';
import 'package:commerce_app/src/core/store_theme.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

/// Product title and description from Medusa `ProductInfo`.
class ProductInfo extends StatelessWidget {
  /// Creates product information for [product].
  const ProductInfo({required this.product, super.key});

  /// Loaded storefront product.
  final Product product;

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.collection case final collection?) ...[
                TextButton(
                  onPressed: () => context.navigator
                      .collection(handle: collection.handle)
                      .push(),
                  style: TextButton.styleFrom(
                    foregroundColor: StoreColors.foregroundMuted,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                  child: Text(collection.title),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                product.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 32,
                      height: 4 / 3,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                product.description ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: StoreColors.foregroundSubtle,
                    ),
              ),
            ],
          ),
        ),
      );
}
