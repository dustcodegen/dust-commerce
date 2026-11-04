part of 'product_listing_view_model.dart';

/// Stable key used to suppress stale listing state between routes.
String listingRequestKey(
  String kind,
  String handle,
  int page,
  String sortBy, [
  List<String> optionValueIds = const [],
  List<String> categoryHandles = const [],
  List<String> labelValues = const [],
  String currencyCode = 'usd',
  String searchQuery = '',
  Option<int> minPrice = const None(),
  Option<int> maxPrice = const None(),
  String saleKey = '',
]) =>
    '$kind:$handle:${page < 1 ? 1 : page}:${normalizedProductSort(sortBy)}:'
    '${normalizedOptionValueIds(optionValueIds).join(',')}:'
    '${normalizedCategoryHandles(categoryHandles).join(',')}:'
    '${normalizedLabelValues(labelValues).join(',')}:$currencyCode:'
    '${normalizedSearchQuery(searchQuery)}:${_optionKey(minPrice)}:'
    '${_optionKey(maxPrice)}:$saleKey';

/// Keeps Store search predictable and bounded before it reaches the API.
String normalizedSearchQuery(String value) {
  final query = value.trim();
  return query.length <= 120 ? query : query.substring(0, 120);
}

/// Removes empty and duplicate option values while preserving URL order.
List<String> normalizedOptionValueIds(Iterable<String> values) =>
    _normalizedTokens(values);

/// Removes empty and duplicate category handles while preserving URL order.
List<String> normalizedCategoryHandles(Iterable<String> values) =>
    _normalizedTokens(values);

/// Removes empty and duplicate label values while preserving URL order.
List<String> normalizedLabelValues(Iterable<String> values) =>
    _normalizedTokens(values);

/// Keeps optional price URL params non-negative and explicit.
Option<int> normalizedPriceBoundary(int? value) =>
    value == null || value < 0 ? const None<int>() : Some<int>(value);

/// Normalizes the Store on-sale toggle query.
bool normalizedOnSale(String value) => value == 'true' || value == '1';

/// Restricts public sort query values to the source-supported set.
String normalizedProductSort(String value) => const {
      'relevance',
      'created_at',
      'price_asc',
      'price_desc',
      'title_asc',
      'title_desc',
    }.contains(value)
        ? value
        : 'created_at';

String? _nullable(Option<String> value) => switch (value) {
      Some(:final value) => value,
      None() => null,
    };

int? _nullableInt(Option<int> value) => switch (value) {
      Some(:final value) => value,
      None() => null,
    };

String _optionKey(Option<int> value) => switch (value) {
      Some(:final value) => '$value',
      None() => '',
    };

List<String> _categoryHandles(_ListingMeta meta) {
  if (meta.selectedCategoryHandles.isNotEmpty) {
    return meta.selectedCategoryHandles;
  }
  return switch (meta.category) {
    Some(:final value) => [value],
    None() => const [],
  };
}

List<String> _normalizedTokens(Iterable<String> values) {
  final result = <String>[];
  final seen = <String>{};
  for (final raw in values) {
    final value = raw.trim();
    if (value.isNotEmpty && seen.add(value)) result.add(value);
  }
  return List.unmodifiable(result);
}
