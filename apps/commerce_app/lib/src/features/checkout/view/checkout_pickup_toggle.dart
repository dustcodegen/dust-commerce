import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_radio_mark.dart';

/// Medusa-shaped switch into the store-pickup choice group.
final class CheckoutPickupToggle extends StatelessWidget {
  /// Creates the pickup mode choice.
  const CheckoutPickupToggle({
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  /// Whether pickup is the selected fulfillment mode.
  final bool selected;

  /// Whether another delivery mutation is not in flight.
  final bool enabled;

  /// Selects the first eligible pickup option.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        checked: selected,
        enabled: enabled,
        inMutuallyExclusiveGroup: true,
        label: context.tr(
          'shop_checkout_pickup_order',
          defaultText: 'Pick up your order',
        ),
        child: ExcludeSemantics(
          child: Material(
            color: StoreColors.base,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: selected ? StoreColors.interactive : StoreColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    CheckoutRadioMark(selected: selected, enabled: enabled),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: TranslatedText(
                        'shop_checkout_pickup_order',
                        defaultText: 'Pick up your order',
                      ),
                    ),
                    const TranslatedText(
                      'shop_checkout_pickup_price',
                      defaultText: '-',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
