import 'package:commerce_app/src/core/store_theme.dart';
import 'package:commerce_app/src/features/catalog/model/product_listing_state.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source-shaped Labels refinement group for the Store sidebar.
class ListingLabelFilters extends StatelessWidget {
  /// Creates the label checkbox list.
  const ListingLabelFilters({
    required this.labels,
    required this.selectedValues,
    required this.onChanged,
    super.key,
  });

  /// Replaces the complete label selection after a checkbox toggle.
  final ValueChanged<List<String>> onChanged;

  /// Available labels with matching-product counts.
  final List<ProductLabelFilter> labels;

  /// Stable label values active in the URL.
  final List<String> selectedValues;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'shop_labels',
            defaultText: 'Labels',
            style: TextStyle(
              color: StoreColors.foregroundSubtle,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              children: [
                for (final (index, label) in labels.indexed) ...[
                  _LabelChoice(
                    label: label,
                    selected: selectedValues.contains(label.value),
                    onChanged: () => onChanged(_toggled(label.value)),
                  ),
                  if (index != labels.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      );

  List<String> _toggled(String value) {
    final selected = selectedValues.toSet();
    selected.contains(value) ? selected.remove(value) : selected.add(value);
    return List.unmodifiable(selected);
  }
}

class _LabelChoice extends StatelessWidget {
  const _LabelChoice({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final ProductLabelFilter label;
  final VoidCallback onChanged;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
        checked: selected,
        button: true,
        child: InkWell(
          onTap: onChanged,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox.square(
                  dimension: 18,
                  child: Checkbox(
                    value: selected,
                    onChanged: (_) => onChanged(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.value,
                  style: TextStyle(
                    color: selected
                        ? StoreColors.foreground
                        : StoreColors.foregroundSubtle,
                    fontSize: 12,
                    height: 20 / 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${label.count})',
                style: const TextStyle(
                  color: StoreColors.foregroundMuted,
                  fontSize: 12,
                  height: 20 / 12,
                ),
              ),
            ],
          ),
        ),
      );
}
