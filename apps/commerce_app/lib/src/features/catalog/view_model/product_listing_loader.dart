part of 'product_listing_view_model.dart';

extension _ProductListingLoader on ProductListingViewModel {
  Future<void> _loadProducts(
    _ListingMeta meta,
    int revision, {
    Future<List<ProductOptionFilterView>>? optionFilters,
    Future<List<ProductCategoryFilter>>? categoryFilters,
    Future<List<ProductLabelFilter>>? labelFilters,
    Future<Option<ProductPriceBounds>>? priceBounds,
  }) async {
    try {
      final productRequest = args.api.products(
        currency: meta.currencyCode,
        query: meta.searchQuery.isEmpty ? null : meta.searchQuery,
        sortBy: meta.sortBy,
        collection: _nullable(meta.collection),
        categoryHandles: _categoryHandles(meta),
        labels: meta.selectedLabelValues,
        maxPrice: _nullableInt(meta.selectedMaxPrice),
        minPrice: _nullableInt(meta.selectedMinPrice),
        onSale: meta.selectedOnSale ? 'true' : null,
        optionValueIds: meta.selectedOptionValueIds,
        limit: ProductListingViewModel._limit,
        offset: (meta.page - 1) * ProductListingViewModel._limit,
      );
      final (result, resolvedMeta) = await _withRefinementFilters(
        productRequest,
        optionFilters,
        categoryFilters,
        labelFilters,
        priceBounds,
        _optionalOnSaleCount(args.api, meta),
        meta,
      );
      if (!_active(revision)) return;
      _setState(resolvedMeta.toState(
        status: ProductListingStatus.ready,
        products: result.products,
        totalPages: (result.total + ProductListingViewModel._limit - 1) ~/
            ProductListingViewModel._limit,
      ));
    } on Object {
      _fail(meta, revision);
    }
  }
}
