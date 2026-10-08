part of 'product_listing_view_model.dart';

Future<int> _optionalOnSaleCount(
  CommerceApi api,
  _ListingMeta meta,
) async {
  try {
    final result = await api.products(
      currency: meta.currencyCode,
      query: meta.searchQuery.isEmpty ? null : meta.searchQuery,
      collection: _nullable(meta.collection),
      categoryHandles: _categoryHandles(meta),
      labels: meta.selectedLabelValues,
      maxPrice: _nullableInt(meta.selectedMaxPrice),
      minPrice: _nullableInt(meta.selectedMinPrice),
      onSale: 'true',
      optionValueIds: meta.selectedOptionValueIds,
      limit: 1,
    );
    return result.total;
  } on Object {
    return meta.onSaleCount;
  }
}
