import 'package:commerce_app/src/core/money.dart';
import 'package:commerce_app/src/features/catalog/model/product_listing_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';

/// Active Store refinement type.
enum ListingRefinementKind {
  /// One selected option value.
  option,

  /// Lower price boundary.
  minPrice,

  /// Upper price boundary.
  maxPrice,

  /// Sale-only toggle.
  onSale,

  /// One selected category handle.
  category,

  /// One selected product label.
  label,
}

/// Returns the Medusa-style chips for active Store refinements.
List<({ListingRefinementKind kind, String label, String value})>
    listingCurrentRefinementModels({
  required List<ProductOptionFilterView> options,
  required List<String> selectedOptionValueIds,
  required List<ProductCategoryFilter> categoryFilters,
  required List<String> selectedCategoryHandles,
  required List<ProductLabelFilter> labelFilters,
  required List<String> selectedLabelValues,
  required Option<int> selectedMinPrice,
  required Option<int> selectedMaxPrice,
  required bool selectedOnSale,
  required String currencyCode,
}) {
  final optionLabels = _optionLabelsOf(options);
  final categoryNames = {for (final it in categoryFilters) it.handle: it.name};
  return [
    for (final id in selectedOptionValueIds)
      (
        kind: ListingRefinementKind.option,
        value: id,
        label: optionLabels[id] ?? id,
      ),
    if (selectedMinPrice case Some(:final value))
      (
        kind: ListingRefinementKind.minPrice,
        value: '$value',
        label: 'From ${formatMoney(Money.of(value, currencyCode))}',
      ),
    if (selectedMaxPrice case Some(:final value))
      (
        kind: ListingRefinementKind.maxPrice,
        value: '$value',
        label: 'Up to ${formatMoney(Money.of(value, currencyCode))}',
      ),
    if (selectedOnSale)
      (
        kind: ListingRefinementKind.onSale,
        value: 'true',
        label: 'On sale',
      ),
    for (final handle in selectedCategoryHandles)
      (
        kind: ListingRefinementKind.category,
        value: handle,
        label: 'Category: ${categoryNames[handle] ?? handle}',
      ),
    for (final value in selectedLabelValues)
      (
        kind: ListingRefinementKind.label,
        value: value,
        label: 'Label: $value',
      ),
  ];
}

Map<String, String> _optionLabelsOf(List<ProductOptionFilterView> options) => {
      for (final option in options)
        for (final value in option.values)
          value.id: '${option.title}: ${value.value}',
    };
