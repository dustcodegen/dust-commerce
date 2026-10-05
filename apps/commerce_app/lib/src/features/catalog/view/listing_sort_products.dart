import 'package:commerce_app/src/core/store_theme.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source-matched SortProducts control.
class SortProducts extends StatelessWidget {
  /// Creates the Store sort radio list.
  const SortProducts({
    required this.selected,
    required this.onChanged,
    required this.extended,
    super.key,
  });

  /// Whether this is the Store search page with indexed sort choices.
  final bool extended;

  /// Receives one Medusa sort query value.
  final ValueChanged<String> onChanged;

  /// Current Medusa sort query value.
  final String selected;

  /// Medusa-supported sort query values.
  static const sourceChoices = <String>[
    'created_at',
    'price_asc',
    'price_desc',
  ];

  /// Store-search sort query values from the current Medusa source.
  static const storeChoices = <String>[
    'relevance',
    'created_at',
    'price_asc',
    'price_desc',
    'title_asc',
    'title_desc',
  ];

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'shop_sort_by',
            defaultText: 'Sort by',
            style: TextStyle(
              color: StoreColors.foregroundMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (final value in extended ? storeChoices : sourceChoices)
            _SortChoice(
              value: value,
              label: label(context, value),
              selected: selected == value,
              onChanged: onChanged,
            ),
        ],
      );

  /// Customer-facing label for the Medusa sort value.
  static String label(BuildContext context, String value) => switch (value) {
        'relevance' => context.tr(
            'shop_sort_relevance',
            defaultText: 'Relevance',
          ),
        'price_asc' => context.tr(
            'shop_sort_price_asc',
            defaultText: 'Price: Low -> High',
          ),
        'price_desc' => context.tr(
            'shop_sort_price_desc',
            defaultText: 'Price: High -> Low',
          ),
        'title_asc' => context.tr(
            'shop_sort_title_asc',
            defaultText: 'Title: A -> Z',
          ),
        'title_desc' => context.tr(
            'shop_sort_title_desc',
            defaultText: 'Title: Z -> A',
          ),
        _ => context.tr('shop_sort_latest', defaultText: 'Latest Arrivals'),
      };
}

class _SortChoice extends StatelessWidget {
  const _SortChoice({
    required this.value,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final bool selected;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: selected ? null : () => onChanged(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Transform.translate(
              offset: selected ? const Offset(-23, 0) : Offset.zero,
              child: Row(
                children: [
                  if (selected) ...[
                    const SizedBox(
                        width: 16, child: Icon(Icons.circle, size: 8)),
                    const SizedBox(width: 7),
                  ],
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? StoreColors.foreground
                          : StoreColors.foregroundSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
