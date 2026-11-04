part of 'product_listing_view_model.dart';

final class _ListingMeta {
  const _ListingMeta({
    required this.requestKey,
    required this.title,
    required this.page,
    required this.sortBy,
    this.description = '',
    this.parents = const [],
    this.children = const [],
    this.categoryFilters = const [],
    this.labelFilters = const [],
    this.optionFilters = const [],
    this.priceBounds = const None(),
    this.canRefineOnSale = false,
    this.onSaleCount = 0,
    this.selectedCategoryHandles = const [],
    this.selectedLabelValues = const [],
    this.selectedMaxPrice = const None(),
    this.selectedMinPrice = const None(),
    this.selectedOnSale = false,
    this.selectedOptionValueIds = const [],
    this.searchQuery = '',
    this.collection = const None(),
    this.category = const None(),
    this.currencyCode = 'usd',
  });

  final Option<String> category;
  final List<ProductCategoryFilter> categoryFilters;
  final bool canRefineOnSale;
  final List<ProductCategory> children;
  final Option<String> collection;
  final String currencyCode;
  final String description;
  final List<ProductLabelFilter> labelFilters;
  final List<ProductOptionFilterView> optionFilters;
  final int onSaleCount;
  final int page;
  final List<ProductCategory> parents;
  final Option<ProductPriceBounds> priceBounds;
  final String requestKey;
  final String searchQuery;
  final List<String> selectedCategoryHandles;
  final List<String> selectedLabelValues;
  final Option<int> selectedMaxPrice;
  final Option<int> selectedMinPrice;
  final bool selectedOnSale;
  final List<String> selectedOptionValueIds;
  final String sortBy;
  final String title;

  _ListingMeta copyWith({
    String? title,
    String? description,
    List<ProductCategory>? parents,
    List<ProductCategory>? children,
    List<ProductCategoryFilter>? categoryFilters,
    List<ProductLabelFilter>? labelFilters,
    List<ProductOptionFilterView>? optionFilters,
    Option<ProductPriceBounds>? priceBounds,
    bool? canRefineOnSale,
    int? onSaleCount,
  }) =>
      _ListingMeta(
        requestKey: requestKey,
        title: title ?? this.title,
        description: description ?? this.description,
        page: page,
        sortBy: sortBy,
        parents: parents ?? this.parents,
        children: children ?? this.children,
        categoryFilters: categoryFilters ?? this.categoryFilters,
        labelFilters: labelFilters ?? this.labelFilters,
        optionFilters: optionFilters ?? this.optionFilters,
        priceBounds: priceBounds ?? this.priceBounds,
        canRefineOnSale: canRefineOnSale ?? this.canRefineOnSale,
        onSaleCount: onSaleCount ?? this.onSaleCount,
        selectedCategoryHandles: selectedCategoryHandles,
        selectedLabelValues: selectedLabelValues,
        selectedMaxPrice: selectedMaxPrice,
        selectedMinPrice: selectedMinPrice,
        selectedOnSale: selectedOnSale,
        selectedOptionValueIds: selectedOptionValueIds,
        searchQuery: searchQuery,
        collection: collection,
        category: category,
        currencyCode: currencyCode,
      );

  ProductListingState toState({
    required ProductListingStatus status,
    List<Product> products = const [],
    int totalPages = 0,
  }) =>
      ProductListingState(
        status: status,
        requestKey: requestKey,
        title: title,
        description: description,
        parents: parents,
        children: children,
        categoryFilters: categoryFilters,
        labelFilters: labelFilters,
        optionFilters: optionFilters,
        priceBounds: priceBounds,
        canRefineOnSale: canRefineOnSale,
        onSaleCount: onSaleCount,
        selectedCategoryHandles: selectedCategoryHandles,
        selectedLabelValues: selectedLabelValues,
        selectedMaxPrice: selectedMaxPrice,
        selectedMinPrice: selectedMinPrice,
        selectedOnSale: selectedOnSale,
        selectedOptionValueIds: selectedOptionValueIds,
        searchQuery: searchQuery,
        products: products,
        sortBy: sortBy,
        currentPage: page,
        totalPages: totalPages,
        currencyCode: currencyCode,
      );
}
