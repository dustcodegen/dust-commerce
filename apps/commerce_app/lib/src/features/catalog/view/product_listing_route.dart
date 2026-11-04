import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// Connects one typed route to the shared product-listing state machine.
class ProductListingRoute extends StatefulWidget {
  /// Creates a route-owned listing request.
  const ProductListingRoute({
    required this.requestKey,
    required this.load,
    required this.onSortChanged,
    this.onSearchChanged,
    required this.onPageChanged,
    required this.onOptionValuesChanged,
    this.onCategoryHandlesChanged,
    this.onLabelValuesChanged,
    this.onPriceRangeChanged,
    this.onSaleChanged,
    this.onClearRefinements,
    required this.onCategorySelected,
    super.key,
  });

  /// Category breadcrumb and child navigation.
  final ValueChanged<String> onCategorySelected;

  /// Replaces the repeated Store category query and resets pagination.
  final ValueChanged<List<String>>? onCategoryHandlesChanged;

  /// Replaces the repeated Store labels query and resets pagination.
  final ValueChanged<List<String>>? onLabelValuesChanged;

  /// Runs the exact store, collection, or category request.
  final Future<void> Function(ProductListingViewModel viewModel) load;

  /// Changes the route page query.
  final ValueChanged<int> onPageChanged;

  /// Clears Store refinements in one route update.
  final VoidCallback? onClearRefinements;

  /// Replaces the Store price-range query and resets pagination.
  final void Function(int? minPrice, int? maxPrice)? onPriceRangeChanged;

  /// Replaces the Store sale-only query and resets pagination.
  final ValueChanged<bool>? onSaleChanged;

  /// Replaces the repeated option-value query and resets pagination.
  final ValueChanged<List<String>> onOptionValuesChanged;

  /// Changes the route sort query.
  final ValueChanged<String> onSortChanged;

  /// Changes the Store free-text search query.
  final ValueChanged<String>? onSearchChanged;

  /// Route/query identity used to reject state from the previous page.
  final String requestKey;

  @override
  State<ProductListingRoute> createState() => _ProductListingRouteState();
}

class _ProductListingRouteState extends State<ProductListingRoute> {
  @override
  void initState() {
    super.initState();
    _loadAfterFrame();
  }

  void _loadAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_load());
    });
  }

  Future<void> _load() async {
    final viewModel = context.readProductListingViewModel();
    await widget.load(viewModel);
  }

  @override
  Widget build(BuildContext context) => StoreScaffold(
        body: ProductListingView(
          state: context.watchProductListingViewModel().value,
          requestKey: widget.requestKey,
          onRetry: _loadAfterFrame,
          onSortChanged: widget.onSortChanged,
          onSearchChanged: widget.onSearchChanged,
          onPageChanged: widget.onPageChanged,
          onOptionValuesChanged: widget.onOptionValuesChanged,
          onCategoryHandlesChanged: widget.onCategoryHandlesChanged,
          onLabelValuesChanged: widget.onLabelValuesChanged,
          onPriceRangeChanged: widget.onPriceRangeChanged,
          onSaleChanged: widget.onSaleChanged,
          onClearRefinements: widget.onClearRefinements,
          onCategorySelected: widget.onCategorySelected,
        ),
      );
}
