import 'package:commerce_app/src/core/store_theme.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Medusa OnSaleToggle clone for discounted Store results.
class ListingOnSaleToggle extends StatelessWidget {
  /// Creates the sale-only checkbox.
  const ListingOnSaleToggle({
    required this.canRefine,
    required this.count,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// Whether any current product can be narrowed by sale state.
  final bool canRefine;

  /// Number of currently matching sale-priced products.
  final int count;

  /// Whether sale-only filtering is active.
  final bool selected;

  /// Replaces the route sale toggle.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!canRefine && !selected) return const SizedBox.shrink();
    return InkWell(
      onTap: () => onChanged(!selected),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 18,
            child: Checkbox(
              value: selected,
              onChanged: (value) => onChanged(value ?? false),
              activeColor: StoreColors.interactive,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          const TranslatedText(
            'shop_on_sale_only',
            defaultText: 'On sale only',
            style: TextStyle(
              color: StoreColors.foregroundSubtle,
              fontSize: 12,
              height: 20 / 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: const TextStyle(
              color: StoreColors.foregroundMuted,
              fontSize: 12,
              height: 20 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
