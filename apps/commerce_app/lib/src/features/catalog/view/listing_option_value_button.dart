import 'package:commerce_app/src/core/store_theme.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

/// One source-shaped option value toggle.
class ListingOptionValueButton extends StatelessWidget {
  /// Creates a stable value toggle.
  const ListingOptionValueButton({
    required this.value,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  /// Toggles this value in the browser query.
  final VoidCallback onPressed;

  /// Whether this value is currently active.
  final bool selected;

  /// Public value rendered to the customer.
  final ProductOptionValueView value;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        toggled: selected,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(40, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            side: BorderSide(
              color: selected ? StoreColors.interactive : StoreColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundColor:
                selected ? StoreColors.foreground : StoreColors.foregroundMuted,
            textStyle: const TextStyle(fontSize: 12, height: 20 / 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value.value),
              const SizedBox(width: 6),
              Text(
                '(${value.count})',
                style: const TextStyle(color: StoreColors.foregroundMuted),
              ),
            ],
          ),
        ),
      );
}
