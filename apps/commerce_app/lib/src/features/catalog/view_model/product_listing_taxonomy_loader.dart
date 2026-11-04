part of 'product_listing_view_model.dart';

/// Collection and category route loading for the product listing view model.
extension ProductListingTaxonomyLoader on ProductListingViewModel {
  /// Resolves [handle] before loading its products.
  Future<void> loadCollection(
    String handle, {
    int page = 1,
    String sortBy = 'created_at',
    List<String> optionValueIds = const [],
    String currency = 'usd',
  }) async {
    final selected = normalizedOptionValueIds(optionValueIds);
    final meta = _ListingMeta(
      requestKey: listingRequestKey(
        'collection',
        handle,
        page,
        sortBy,
        selected,
        const [],
        const [],
        currency,
      ),
      title: '',
      page: page < 1 ? 1 : page,
      sortBy: normalizedProductSort(sortBy),
      collection: Some(handle),
      selectedOptionValueIds: selected,
      currencyCode: currency,
    );
    final revision = _begin(meta);
    try {
      final result = await args.api.collections(handle: handle, limit: 1);
      if (!_active(revision)) return;
      if (result.collections.isEmpty) return _missing(meta);
      await _loadProducts(
        meta.copyWith(title: result.collections.single.title),
        revision,
      );
    } on Object {
      _fail(meta, revision);
    }
  }

  /// Resolves [handle], its hierarchy, and its products.
  Future<void> loadCategory(
    String handle, {
    int page = 1,
    String sortBy = 'created_at',
    List<String> optionValueIds = const [],
    String currency = 'usd',
  }) async {
    final selected = normalizedOptionValueIds(optionValueIds);
    final meta = _ListingMeta(
      requestKey: listingRequestKey(
        'category',
        handle,
        page,
        sortBy,
        selected,
        const [],
        const [],
        currency,
      ),
      title: '',
      page: page < 1 ? 1 : page,
      sortBy: normalizedProductSort(sortBy),
      category: Some(handle),
      selectedOptionValueIds: selected,
      currencyCode: currency,
    );
    final revision = _begin(meta);
    try {
      final result = await args.api.categories(
        limit: ProductListingViewModel._sourceFetchLimit,
      );
      if (!_active(revision)) return;
      final matches = result.categories.where((it) => it.handle == handle);
      if (matches.isEmpty) return _missing(meta);
      final category = matches.single;
      await _loadProducts(
        meta.copyWith(
          title: category.name,
          description: category.description ?? '',
          parents: _parentsOf(category, result.categories),
          children: result.categories
              .where((it) => it.parentId == category.id)
              .toList(growable: false),
        ),
        revision,
      );
    } on Object {
      _fail(meta, revision);
    }
  }
}
