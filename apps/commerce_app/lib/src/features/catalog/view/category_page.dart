import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:flutter/material.dart';

import 'product_listing_route.dart';

/// Hierarchical category page translated from Medusa CategoryTemplate.
@AppRoute('/categories/:handle', name: 'category', guards: [])
class CategoryPage extends StatelessWidget {
  /// Creates a paged category route.
  const CategoryPage({
    required this.handle,
    this.page = 1,
    this.sortBy = 'created_at',
    this.optionValueIds = const [],
    super.key,
  });

  /// Full category handle from the URL.
  final String handle;

  /// Hidden source-compatible option values retained in the URL.
  final List<String> optionValueIds;

  /// One-based page query.
  final int page;

  /// Medusa-compatible sort query.
  final String sortBy;

  @override
  Widget build(BuildContext context) {
    final currentPage = page < 1 ? 1 : page;
    final currentSort = normalizedProductSort(sortBy);
    final selected = normalizedOptionValueIds(optionValueIds);
    final currency = context.watchStoreShellViewModel().value.currencyCode;
    final requestKey = listingRequestKey(
      'category',
      handle,
      currentPage,
      currentSort,
      selected,
      const [],
      const [],
      currency,
    );
    return ProductListingRoute(
      key: ValueKey(requestKey),
      requestKey: requestKey,
      load: (viewModel) => viewModel.loadCategory(
        handle,
        page: currentPage,
        sortBy: currentSort,
        optionValueIds: selected,
        currency: currency,
      ),
      onSortChanged: (value) => context.navigator
          .category(
            handle: handle,
            sortBy: value,
            optionValueIds: selected,
          )
          .go(),
      onPageChanged: (value) => context.navigator
          .category(
            handle: handle,
            page: value,
            sortBy: currentSort,
            optionValueIds: selected,
          )
          .go(),
      onOptionValuesChanged: (values) => context.navigator
          .category(
            handle: handle,
            sortBy: currentSort,
            optionValueIds: values,
          )
          .go(),
      onClearRefinements: () =>
          context.navigator.category(handle: handle, sortBy: currentSort).go(),
      onCategorySelected: (categoryHandle) =>
          context.navigator.category(handle: categoryHandle).go(),
    );
  }
}
