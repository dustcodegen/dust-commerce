import 'package:commerce_app/src/core/store_theme.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Search input matching the current Medusa drawer.
final class StoreSearchField extends StatelessWidget {
  /// Creates the search field.
  const StoreSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  /// Text controller owned by the drawer.
  final TextEditingController controller;

  /// Debounced upstream change callback.
  final ValueChanged<String> onChanged;

  /// Clears the current query.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final label = context.tr(
      'shop_search_products',
      defaultText: 'Search products',
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: StoreColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 18,
              color: StoreColors.foregroundMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  if (controller.text.isEmpty)
                    ExcludeSemantics(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: StoreColors.foregroundMuted,
                        ),
                      ),
                    ),
                  Semantics(
                    label: label,
                    child: TextField(
                      autofocus: true,
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ),
            if (controller.text.isNotEmpty)
              IconButton(
                tooltip: context.tr(
                  'shop_search_clear',
                  defaultText: 'Clear search',
                ),
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }
}
