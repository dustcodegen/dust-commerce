import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped checkout radio indicator.
final class CheckoutRadioMark extends StatelessWidget {
  /// Creates a source-sized radio mark.
  const CheckoutRadioMark({
    required this.selected,
    this.enabled = true,
    super.key,
  });

  /// Whether this option is selected.
  final bool selected;

  /// Whether the row is interactive.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final border =
        enabled ? StoreColors.border : StoreColors.foregroundDisabled;
    return SizedBox.square(
      dimension: 20,
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: selected && enabled
                ? StoreColors.interactive
                : enabled
                    ? StoreColors.base
                    : StoreColors.subtle,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected && enabled ? StoreColors.interactive : border,
            ),
          ),
          child: selected
              ? Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: enabled
                          ? StoreColors.base
                          : StoreColors.foregroundDisabled,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
