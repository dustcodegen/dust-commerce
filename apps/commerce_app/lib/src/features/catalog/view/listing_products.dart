import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'listing_grid.dart';
import 'listing_header.dart';
import 'listing_search_box.dart';

/// Product grid column paired with the Store refinement sidebar.
class ListingProducts extends StatelessWidget {
  /// Creates the searchable, paginated listing column.
  const ListingProducts({
    required this.state,
    required this.onSearchChanged,
    required this.onPageChanged,
    required this.onCategorySelected,
    this.showHeader = true,
    super.key,
  });

  /// Category breadcrumb and child navigation.
  final ValueChanged<String> onCategorySelected;

  /// Changes the one-based page query.
  final ValueChanged<int> onPageChanged;

  /// Changes the Store free-text search query.
  final ValueChanged<String>? onSearchChanged;

  /// Whether the listing title belongs inside this product column.
  final bool showHeader;

  /// Listing state supplied by its Dust view model.
  final ProductListingState state;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader)
            ListingHeader(
              state: state,
              onCategorySelected: onCategorySelected,
            ),
          if (onSearchChanged case final onSearchChanged?) ...[
            ListingSearchBox(
              query: state.searchQuery,
              onChanged: onSearchChanged,
            ),
          ],
          if (state.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: onSearchChanged == null
                    ? const TranslatedText(
                        'shop_empty',
                        defaultText: 'Nothing for sale yet',
                      )
                    : const TranslatedText(
                        'shop_no_products_matched',
                        defaultText: 'No products matched these filters.',
                        style: TextStyle(color: StoreColors.foregroundSubtle),
                      ),
              ),
            )
          else
            ListingGrid(
              products: state.products,
              currencyCode: state.currencyCode,
              currentPage: state.currentPage,
              totalPages: state.totalPages,
              onPageChanged: onPageChanged,
            ),
        ],
      );
}
