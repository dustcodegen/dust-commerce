import 'package:commerce_app/src/core/store_theme.dart';
import 'package:commerce_app/src/features/catalog/model/product_listing_state.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source-shaped Category refinement group for the Store sidebar.
class ListingCategoryFilters extends StatelessWidget {
  /// Creates the category checkbox list.
  const ListingCategoryFilters({
    required this.categories,
    required this.selectedHandles,
    required this.onChanged,
    super.key,
  });

  /// Replaces the complete category selection after a checkbox toggle.
  final ValueChanged<List<String>> onChanged;

  /// Available categories with matching-product counts.
  final List<ProductCategoryFilter> categories;

  /// Stable category handles active in the URL.
  final List<String> selectedHandles;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'shop_category',
            defaultText: 'Category',
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
                for (final (index, category) in categories.indexed) ...[
                  _CategoryChoice(
                    category: category,
                    selected: selectedHandles.contains(category.handle),
                    onChanged: () => onChanged(_toggled(category.handle)),
                  ),
                  if (index != categories.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      );

  List<String> _toggled(String handle) {
    final selected = selectedHandles.toSet();
    selected.contains(handle) ? selected.remove(handle) : selected.add(handle);
    return List.unmodifiable(selected);
  }
}

class _CategoryChoice extends StatelessWidget {
  const _CategoryChoice({
    required this.category,
    required this.selected,
    required this.onChanged,
  });

  final ProductCategoryFilter category;
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
              SizedBox.square(
                dimension: 18,
                child: Checkbox(
                  value: selected,
                  onChanged: (_) => onChanged(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: selected
                        ? StoreColors.foreground
                        : StoreColors.foregroundSubtle,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${category.count})',
                style: const TextStyle(
                  color: StoreColors.foregroundMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
}
