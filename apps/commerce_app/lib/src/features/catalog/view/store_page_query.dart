part of 'store_page.dart';

final class _StorePageQuery {
  const _StorePageQuery({
    required this.page,
    required this.q,
    required this.sortBy,
    required this.optionValueIds,
    required this.category,
    required this.labels,
    required this.minPrice,
    required this.maxPrice,
    required this.onSale,
    required this.currency,
  });

  factory _StorePageQuery.of(StorePage source, BuildContext context) =>
      _StorePageQuery(
        page: source.page < 1 ? 1 : source.page,
        q: normalizedSearchQuery(source.q),
        sortBy: normalizedProductSort(source.sortBy),
        optionValueIds: normalizedOptionValueIds(source.optionValueIds),
        category: normalizedCategoryHandles(source.category),
        labels: normalizedLabelValues(source.labels),
        minPrice: normalizedPriceBoundary(source.minPrice),
        maxPrice: normalizedPriceBoundary(source.maxPrice),
        onSale: normalizedOnSale(source.onSale),
        currency: context.watchStoreShellViewModel().value.currencyCode,
      );

  final List<String> category;
  final String currency;
  final List<String> labels;
  final Option<int> maxPrice;
  final Option<int> minPrice;
  final bool onSale;
  final List<String> optionValueIds;
  final int page;
  final String q;
  final String sortBy;

  String get requestKey => listingRequestKey(
        'store',
        '',
        page,
        sortBy,
        optionValueIds,
        category,
        labels,
        currency,
        q,
        minPrice,
        maxPrice,
        onSale ? 'sale' : '',
      );

  Future<void> load(ProductListingViewModel viewModel) => viewModel.loadStore(
        page: page,
        query: q,
        sortBy: sortBy,
        optionValueIds: optionValueIds,
        categoryHandles: category,
        labels: labels,
        minPrice: minPrice,
        maxPrice: maxPrice,
        onSale: onSale,
        currency: currency,
      );

  void clear(BuildContext context) {
    context.navigator.store(q: q, sortBy: sortBy).go();
  }

  void go(
    BuildContext context, {
    int? page,
    String? q,
    String? sortBy,
    List<String>? optionValueIds,
    List<String>? category,
    List<String>? labels,
    bool? onSale,
  }) {
    context.navigator
        .store(
          q: q ?? this.q,
          page: page ?? 1,
          sortBy: sortBy ?? this.sortBy,
          optionValueIds: optionValueIds ?? this.optionValueIds,
          category: category ?? this.category,
          labels: labels ?? this.labels,
          minPrice: _valueOf(minPrice),
          maxPrice: _valueOf(maxPrice),
          onSale: (onSale ?? this.onSale) ? 'true' : '',
        )
        .go();
  }

  void goPrice(BuildContext context, int? minPrice, int? maxPrice) {
    context.navigator
        .store(
          q: q,
          sortBy: sortBy,
          optionValueIds: optionValueIds,
          category: category,
          labels: labels,
          minPrice: minPrice,
          maxPrice: maxPrice,
          onSale: onSale ? 'true' : '',
        )
        .go();
  }

  int? _valueOf(Option<int> value) => switch (value) {
        Some(:final value) => value,
        None() => null,
      };
}
