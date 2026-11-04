import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_delivery_choice.dart';
import 'checkout_primary_action.dart';

/// Expanded server-priced delivery choices and progression action.
final class CheckoutDeliveryChoices extends StatelessWidget {
  /// Creates the delivery-choice list.
  const CheckoutDeliveryChoices({
    required this.cart,
    required this.selected,
    required this.state,
    super.key,
  });

  /// Current server-authoritative cart and shipping choices.
  final CartState cart;

  /// Shipping method selected on the cart.
  final ShippingMethod? selected;

  /// Checkout operation state.
  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final shippingOptions = cart.shippingOptions.where(
      (option) => option.fulfillmentType == ShippingFulfillmentType.shipping,
    );
    final pickupOptions = cart.shippingOptions.where(
      (option) => option.fulfillmentType == ShippingFulfillmentType.pickup,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TranslatedText(
          'shop_checkout_shipping_method',
          defaultText: 'Shipping method',
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const TranslatedText(
          'shop_checkout_delivery_prompt',
          defaultText: 'How would you like your order delivered',
          style: TextStyle(
            color: StoreColors.foregroundMuted,
            fontSize: 14,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 16),
        if (cart.shippingOptions.isEmpty && state.isBusy)
          const Center(child: CircularProgressIndicator())
        else ...[
          for (final option in shippingOptions) ...[
            CheckoutDeliveryChoice(
              option: option,
              selected: selected?.optionId == option.optionId,
              available: option.isAvailableFor(cart.cart!.subtotal),
              enabled: !state.isBusy,
              onTap: () => context
                  .readCheckoutViewModel()
                  .chooseDelivery(option.optionId),
            ),
            const SizedBox(height: 8),
          ],
          if (pickupOptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const TranslatedText(
              'shop_checkout_pickup_store',
              defaultText: 'Store',
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const TranslatedText(
              'shop_checkout_pickup_prompt',
              defaultText: 'Choose a store near you',
              style: TextStyle(
                color: StoreColors.foregroundMuted,
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
            const SizedBox(height: 16),
            for (final option in pickupOptions) ...[
              CheckoutDeliveryChoice(
                option: option,
                selected: selected?.optionId == option.optionId,
                available: option.isAvailableFor(cart.cart!.subtotal),
                enabled: !state.isBusy,
                onTap: () => context
                    .readCheckoutViewModel()
                    .chooseDelivery(option.optionId),
              ),
              const SizedBox(height: 8),
            ],
          ],
          if (state.status == CheckoutStatus.failed &&
              state.operation == CheckoutOperation.delivery) ...[
            StoreErrorMessage(state.message!),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: state.isBusy
                    ? null
                    : context.readCheckoutViewModel().loadDelivery,
                child: const TranslatedText(
                  'shop_retry',
                  defaultText: 'Try again',
                ),
              ),
            ),
          ],
        ],
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: CheckoutPrimaryAction(
            label: context.tr(
              'shop_checkout_continue_payment',
              defaultText: 'Continue to payment',
            ),
            onPressed: selected == null || state.isBusy
                ? null
                : () => context.pushCheckoutStep('payment'),
          ),
        ),
      ],
    );
  }
}
