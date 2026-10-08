import 'package:commerce_app/src/core/store_theme.dart';
import 'package:commerce_app/src/features/catalog/model/product_listing_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'listing_current_refinement_chip.dart';
import 'listing_current_refinement_models.dart';

/// Medusa CurrentRefinements clone for the Store sidebar.
class ListingCurrentRefinements extends StatelessWidget {
  /// Creates active refinement chips.
  const ListingCurrentRefinements({
    required this.options,
    required this.selectedOptionValueIds,
    required this.onOptionValuesChanged,
    required this.categoryFilters,
    required this.selectedCategoryHandles,
    required this.labelFilters,
    required this.selectedLabelValues,
    required this.selectedMaxPrice,
    required this.selectedMinPrice,
    required this.selectedOnSale,
    required this.currencyCode,
    this.onCategoryHandlesChanged,
    this.onLabelValuesChanged,
    this.onPriceRangeChanged,
    this.onSaleChanged,
    this.onClearAll,
    super.key,
  });

  /// Store-only category refinements discovered from matching products.
  final List<ProductCategoryFilter> categoryFilters;

  /// Currency used by price chip labels.
  final String currencyCode;

  /// Store-only label refinements discovered from matching products.
  final List<ProductLabelFilter> labelFilters;

  /// Clears every Store refinement in one route update.
  final VoidCallback? onClearAll;

  /// Replaces the repeated category query.
  final ValueChanged<List<String>>? onCategoryHandlesChanged;

  /// Replaces the repeated labels query.
  final ValueChanged<List<String>>? onLabelValuesChanged;

  /// Replaces the repeated option-value query.
  final ValueChanged<List<String>> onOptionValuesChanged;

  /// Replaces the price range query.
  final void Function(int? minPrice, int? maxPrice)? onPriceRangeChanged;

  /// Replaces the sale-only query toggle.
  final ValueChanged<bool>? onSaleChanged;

  /// Store-only option axes discovered from the backend.
  final List<ProductOptionFilterView> options;

  /// Stable category handles currently selected.
  final List<String> selectedCategoryHandles;

  /// Stable label values currently selected.
  final List<String> selectedLabelValues;

  /// Active upper price bound in minor units.
  final Option<int> selectedMaxPrice;

  /// Active lower price bound in minor units.
  final Option<int> selectedMinPrice;

  /// Whether only sale-priced products are shown.
  final bool selectedOnSale;

  /// Stable option-value identifiers currently selected.
  final List<String> selectedOptionValueIds;

  @override
  Widget build(BuildContext context) {
    final chips = listingCurrentRefinementModels(
      options: options,
      selectedOptionValueIds: selectedOptionValueIds,
      categoryFilters: categoryFilters,
      selectedCategoryHandles: selectedCategoryHandles,
      labelFilters: labelFilters,
      selectedLabelValues: selectedLabelValues,
      selectedMinPrice: selectedMinPrice,
      selectedMaxPrice: selectedMaxPrice,
      selectedOnSale: selectedOnSale,
      currencyCode: currencyCode,
    );
    if (chips.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 48),
        _CurrentHeader(onClearAll: onClearAll),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final chip in chips)
                ListingCurrentRefinementChip(
                  label: chip.label,
                  onPressed: () => _remove(chip),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _remove(
    ({ListingRefinementKind kind, String label, String value}) chip,
  ) {
    switch (chip.kind) {
      case ListingRefinementKind.option:
        onOptionValuesChanged(_without(selectedOptionValueIds, chip.value));
      case ListingRefinementKind.minPrice:
        onPriceRangeChanged?.call(null, _intOf(selectedMaxPrice));
      case ListingRefinementKind.maxPrice:
        onPriceRangeChanged?.call(_intOf(selectedMinPrice), null);
      case ListingRefinementKind.onSale:
        onSaleChanged?.call(false);
      case ListingRefinementKind.category:
        onCategoryHandlesChanged?.call(
          _without(selectedCategoryHandles, chip.value),
        );
      case ListingRefinementKind.label:
        onLabelValuesChanged?.call(_without(selectedLabelValues, chip.value));
    }
  }
}

class _CurrentHeader extends StatelessWidget {
  const _CurrentHeader({required this.onClearAll});

  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 24),
        child: Row(
          children: [
            const Expanded(
              child: TranslatedText(
                'shop_applied_filters',
                defaultText: 'Applied filters',
                style: TextStyle(
                  color: StoreColors.foregroundSubtle,
                  fontSize: 12,
                  height: 20 / 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                foregroundColor: StoreColors.interactive,
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  height: 20 / 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(
                context.tr('shop_clear_all', defaultText: 'Clear all'),
              ),
            ),
          ],
        ),
      );
}

List<String> _without(List<String> values, String removed) =>
    values.where((value) => value != removed).toList(growable: false);

int? _intOf(Option<int> value) => switch (value) {
      Some(:final value) => value,
      None() => null,
    };
