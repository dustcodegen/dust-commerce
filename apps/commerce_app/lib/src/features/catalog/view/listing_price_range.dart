import 'package:commerce_app/src/core/money.dart';
import 'package:commerce_app/src/core/store_theme.dart';
import 'package:commerce_app/src/features/catalog/model/product_listing_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped PriceRange refinement over cheapest product price.
class ListingPriceRange extends StatefulWidget {
  /// Creates the store-only price slider.
  const ListingPriceRange({
    required this.bounds,
    required this.currencyCode,
    required this.selectedMaxPrice,
    required this.selectedMinPrice,
    required this.onChanged,
    super.key,
  });

  /// Discovered minimum and maximum cheapest-product prices.
  final Option<ProductPriceBounds> bounds;

  /// Currency used by the visible labels.
  final String currencyCode;

  /// Replaces the URL price query after the drag commits.
  final void Function(int? minPrice, int? maxPrice) onChanged;

  /// Active upper bound in minor units.
  final Option<int> selectedMaxPrice;

  /// Active lower bound in minor units.
  final Option<int> selectedMinPrice;

  @override
  State<ListingPriceRange> createState() => _ListingPriceRangeState();
}

class _ListingPriceRangeState extends State<ListingPriceRange> {
  RangeValues? _value;

  @override
  void didUpdateWidget(covariant ListingPriceRange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bounds != widget.bounds ||
        oldWidget.selectedMinPrice != widget.selectedMinPrice ||
        oldWidget.selectedMaxPrice != widget.selectedMaxPrice) {
      _value = null;
    }
  }

  @override
  Widget build(BuildContext context) => switch (widget.bounds) {
        Some(value: final bounds) when bounds.canRefine => _PriceRangeBody(
            bounds: bounds,
            currencyCode: widget.currencyCode,
            value: _value ?? _selected(bounds),
            onChanged: (value) => setState(() => _value = value),
            onChangeEnd: (value) => _commit(bounds, value),
          ),
        _ => const SizedBox.shrink(),
      };

  RangeValues _selected(ProductPriceBounds bounds) {
    final min = _clamped(widget.selectedMinPrice, bounds, fallback: bounds.min);
    final max = _clamped(widget.selectedMaxPrice, bounds, fallback: bounds.max);
    return RangeValues(min.toDouble(), (max < min ? min : max).toDouble());
  }

  int _clamped(
    Option<int> value,
    ProductPriceBounds bounds, {
    required int fallback,
  }) =>
      switch (value) {
        Some(value: final price) => price.clamp(bounds.min, bounds.max),
        None() => fallback,
      };

  void _commit(ProductPriceBounds bounds, RangeValues value) {
    final min = value.start.round();
    final max = value.end.round();
    widget.onChanged(
      min <= bounds.min ? null : min,
      max >= bounds.max ? null : max,
    );
  }
}

class _PriceRangeBody extends StatelessWidget {
  const _PriceRangeBody({
    required this.bounds,
    required this.currencyCode,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final ProductPriceBounds bounds;
  final String currencyCode;
  final ValueChanged<RangeValues> onChanged;
  final ValueChanged<RangeValues> onChangeEnd;
  final RangeValues value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'shop_price',
            defaultText: 'Price',
            style: TextStyle(
              color: StoreColors.foregroundSubtle,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              children: [
                Semantics(
                  label: context.tr('shop_price', defaultText: 'Price'),
                  value: '${_money(value.start)} - ${_money(value.end)}',
                  child: SizedBox(
                    height: 20,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: StoreColors.interactive,
                        inactiveTrackColor: StoreColors.border,
                        overlayShape: SliderComponentShape.noOverlay,
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        thumbColor: StoreColors.base,
                        trackHeight: 2,
                      ),
                      child: RangeSlider(
                        values: value,
                        min: bounds.min.toDouble(),
                        max: bounds.max.toDouble(),
                        divisions: bounds.max - bounds.min,
                        labels: RangeLabels(
                          _money(value.start),
                          _money(value.end),
                        ),
                        semanticFormatterCallback: _money,
                        onChanged: onChanged,
                        onChangeEnd: onChangeEnd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_money(value.start), style: _labelStyle),
                    Text(_money(value.end), style: _labelStyle),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

  String _money(double amount) => formatMoney(
        Money.of(amount.round(), currencyCode),
      );

  static const _labelStyle = TextStyle(
    color: StoreColors.foregroundSubtle,
    fontSize: 12,
    height: 20 / 12,
  );
}
