import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/catalog/model/product_listing_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'product_listing_view_model.g.dart';
part 'product_listing_loader.dart';
part 'product_listing_meta.dart';
part 'product_listing_query.dart';
part 'product_listing_refinement_support.dart';
part 'product_listing_sale_refinement.dart';
part 'product_listing_support.dart';
part 'product_listing_taxonomy_loader.dart';

/// Dependencies for source-shaped product listing routes.
final class ProductListingViewModelArgs extends ViewModelArgs {
  /// Creates typed listing dependencies.
  const ProductListingViewModelArgs({required this.api, super.observer});

  /// Storefront API used by every listing route.
  final CommerceApi api;
}

/// Loads store, collection, and category routes without widget-owned data.
@ViewModel(state: ProductListingState, args: ProductListingViewModelArgs)
class ProductListingViewModel extends $ProductListingViewModel {
  /// Creates the listing state machine.
  ProductListingViewModel(super.args);

  static const _limit = 12;
  static const _sourceFetchLimit = 100;
  int _revision = 0;

  /// Loads the source `/store` route.
  Future<void> loadStore({
    int page = 1,
    String sortBy = 'relevance',
    String query = '',
    List<String> optionValueIds = const [],
    List<String> categoryHandles = const [],
    List<String> labels = const [],
    Option<int> minPrice = const None(),
    Option<int> maxPrice = const None(),
    bool onSale = false,
    String currency = 'usd',
  }) async {
    final selected = normalizedOptionValueIds(optionValueIds);
    final selectedCategories = normalizedCategoryHandles(categoryHandles);
    final selectedLabels = normalizedLabelValues(labels);
    final search = normalizedSearchQuery(query);
    final meta = _ListingMeta(
      requestKey: listingRequestKey(
        'store',
        '',
        page,
        sortBy,
        selected,
        selectedCategories,
        selectedLabels,
        currency,
        search,
        minPrice,
        maxPrice,
        onSale ? 'sale' : '',
      ),
      title: 'All products',
      page: page < 1 ? 1 : page,
      sortBy: normalizedProductSort(sortBy),
      searchQuery: search,
      selectedCategoryHandles: selectedCategories,
      selectedLabelValues: selectedLabels,
      selectedMaxPrice: maxPrice,
      selectedMinPrice: minPrice,
      selectedOnSale: onSale,
      selectedOptionValueIds: selected,
      currencyCode: currency,
    );
    final revision = _begin(meta);
    await _loadProducts(
      meta,
      revision,
      optionFilters: _optionalOptionFilters(args.api, _sourceFetchLimit),
      categoryFilters:
          _optionalCategoryFilters(args.api, _sourceFetchLimit, meta),
      labelFilters: _optionalLabelFilters(args.api, _sourceFetchLimit, meta),
      priceBounds: _optionalPriceBounds(args.api, _sourceFetchLimit, meta),
    );
  }

  void _setState(ProductListingState next) => emit(next);
}
