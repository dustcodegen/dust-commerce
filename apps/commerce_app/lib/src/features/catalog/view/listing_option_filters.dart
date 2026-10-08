import 'package:commerce_app/src/core/store_theme.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'listing_option_value_button.dart';

/// Source-matched option accordions backed by stable value identifiers.
class ListingOptionFilters extends StatefulWidget {
  /// Creates the store-only option picker.
  const ListingOptionFilters({
    required this.options,
    required this.selectedValueIds,
    required this.onChanged,
    super.key,
  });

  /// Replaces the complete selection after a value is toggled.
  final ValueChanged<List<String>> onChanged;

  /// Public option filters returned by the store endpoint.
  final List<ProductOptionFilterView> options;

  /// Stable value identifiers active in the URL.
  final List<String> selectedValueIds;

  @override
  State<ListingOptionFilters> createState() => _ListingOptionFiltersState();
}

class _ListingOptionFiltersState extends State<ListingOptionFilters> {
  late final Set<String> _open = {
    for (final option in widget.options) option.id,
  };

  @override
  void didUpdateWidget(covariant ListingOptionFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.options.map((option) => option.id).toSet();
    for (final option in widget.options) {
      if (!previous.contains(option.id)) _open.add(option.id);
    }
  }

  void _toggleValue(String valueId) {
    final selected = widget.selectedValueIds.toSet();
    selected.contains(valueId)
        ? selected.remove(valueId)
        : selected.add(valueId);
    widget.onChanged(List.unmodifiable(selected));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, option) in widget.options.indexed) ...[
              _OptionGroup(
                option: option,
                open: _open.contains(option.id),
                selectedValueIds: widget.selectedValueIds,
                onOpenChanged: () => setState(() {
                  _open.contains(option.id)
                      ? _open.remove(option.id)
                      : _open.add(option.id);
                }),
                onValueChanged: _toggleValue,
              ),
              if (index != widget.options.length - 1)
                const SizedBox(height: 12),
            ],
          ],
        ),
      );
}

class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.option,
    required this.open,
    required this.selectedValueIds,
    required this.onOpenChanged,
    required this.onValueChanged,
  });

  final VoidCallback onOpenChanged;
  final ValueChanged<String> onValueChanged;
  final bool open;
  final ProductOptionFilterView option;
  final List<String> selectedValueIds;

  @override
  Widget build(BuildContext context) {
    final selectedCount = option.values
        .where((value) => selectedValueIds.contains(value.id))
        .length;
    final title = option.title.trim().isEmpty
        ? context.tr('shop_option_fallback', defaultText: 'Option')
        : option.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onOpenChanged,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: StoreColors.foreground,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($selectedCount)',
                        style: const TextStyle(
                          color: StoreColors.foregroundMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: open ? .5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: const SizedBox.square(
                    dimension: 28,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: StoreColors.foregroundMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final value in option.values)
                        ListingOptionValueButton(
                          value: value,
                          selected: selectedValueIds.contains(value.id),
                          onPressed: () => onValueChanged(value.id),
                        ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
