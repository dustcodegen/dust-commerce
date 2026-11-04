import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source home ProductRail backed by one real collection filter.
class FeaturedProductRailView extends StatelessWidget {
  /// Creates a collection rail.
  const FeaturedProductRailView({
    required this.rail,
    required this.currencyCode,
    super.key,
  });

  /// Currency used by every product card.
  final String currencyCode;

  /// Collection and products loaded together by the home state machine.
  final FeaturedProductRail rail;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: MediaQuery.sizeOf(context).width >= 1024 ? 96 : 48,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth <= 0) {
                  return const SizedBox.shrink();
                }
                final desktop = constraints.maxWidth >= 976;
                const spacing = 24.0;
                final preferredColumns = desktop ? 3 : 2;
                final columns =
                    constraints.maxWidth < spacing ? 1 : preferredColumns;
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * spacing) / columns;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TranslatedText.dynamic(
                            'shop_collection_${rail.collection.id}',
                            fallback: rail.collection.title,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: StoreInteractiveLink(
                              onPressed: () => context.navigator
                                  .collection(handle: rail.collection.handle)
                                  .go(),
                              child: const TranslatedText(
                                'shop_view_all',
                                defaultText: 'View all',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: spacing,
                      runSpacing: desktop ? 144 : 96,
                      children: [
                        for (final product in rail.products)
                          SizedBox(
                            width: cardWidth,
                            child: ProductCard(
                              product: product,
                              currencyCode: currencyCode,
                              featured: true,
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}
