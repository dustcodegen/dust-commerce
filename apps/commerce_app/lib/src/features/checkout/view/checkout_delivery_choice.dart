import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

import 'checkout_radio_mark.dart';

/// Source-shaped delivery radio row with explicit selection semantics.
final class CheckoutDeliveryChoice extends StatelessWidget {
  /// Creates one server-priced delivery choice.
  const CheckoutDeliveryChoice({
    required this.option,
    required this.selected,
    required this.available,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  /// Whether the cart satisfies this option's server-owned rules.
  final bool available;

  /// Whether another delivery mutation permits interaction.
  final bool enabled;

  /// Selects this option through the checkout ViewModel.
  final VoidCallback onTap;

  /// Public delivery option returned for the current cart.
  final ShippingOption option;

  /// Whether this option is retained on the cart.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final price = option.fulfillmentType == ShippingFulfillmentType.pickup
        ? '-'
        : available
            ? formatMoney(option.amount)
            : '-';
    return Semantics(
      button: true,
      checked: selected,
      enabled: enabled && available,
      inMutuallyExclusiveGroup: true,
      label: '${option.name} $price',
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
            onTap: enabled && available ? onTap : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              child: Row(
                children: [
                  CheckoutRadioMark(selected: selected, enabled: available),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.fulfillmentType ==
                                  ShippingFulfillmentType.pickup
                              ? option.pickupName ?? option.name
                              : option.name,
                          style: TextStyle(
                            color: available
                                ? StoreColors.foreground
                                : StoreColors.foregroundDisabled,
                          ),
                        ),
                        if (option.fulfillmentType ==
                                ShippingFulfillmentType.pickup &&
                            option.pickupAddress != null)
                          Text(
                            option.pickupAddress!,
                            style: const TextStyle(
                              color: StoreColors.foregroundMuted,
                              fontSize: 14,
                              height: 20 / 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(price),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
