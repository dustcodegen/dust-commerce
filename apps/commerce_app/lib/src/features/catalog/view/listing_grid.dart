import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

import 'listing_pagination.dart';

/// Source grid plus pagination for a completed listing.
class ListingGrid extends StatelessWidget {
  /// Creates a responsive product grid.
  const ListingGrid({
    required this.products,
    required this.currencyCode,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.searchPagination = false,
    super.key,
  });

  /// One-based active page.
  final int currentPage;

  /// Currency used by product cards.
  final String currencyCode;

  /// Changes the page query.
  final ValueChanged<int> onPageChanged;

  /// Products on this page.
  final List<Product> products;

  /// Whether this grid follows StoreHits search pagination.
  final bool searchPagination;

  /// Number of available pages.
  final int totalPages;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 0) {
            return const SizedBox.shrink();
          }
          final viewportWidth = MediaQuery.sizeOf(context).width;
          final preferredColumns = viewportWidth >= 1280
              ? 4
              : viewportWidth >= 1024
                  ? 3
                  : 2;
          const spacing = 24.0;
          final columns = constraints.maxWidth < spacing ? 1 : preferredColumns;
          final cardWidth =
              (constraints.maxWidth - (columns - 1) * spacing) / columns;
          return Column(
            children: [
              Wrap(
                spacing: spacing,
                runSpacing: 32,
                children: [
                  for (final product in products)
                    SizedBox(
                      width: cardWidth,
                      child: ProductCard(
                        product: product,
                        currencyCode: currencyCode,
                      ),
                    ),
                ],
              ),
              if (totalPages > 1) ...[
                const SizedBox(height: 48),
                ListingPagination(
                  currentPage: currentPage,
                  search: searchPagination,
                  totalPages: totalPages,
                  onPageChanged: onPageChanged,
                ),
              ],
            ],
          );
        },
      );
}
