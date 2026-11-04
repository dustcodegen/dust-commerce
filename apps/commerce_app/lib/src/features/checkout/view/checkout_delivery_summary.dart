import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Collapsed delivery method accepted by the server-owned cart.
final class CheckoutDeliverySummary extends StatelessWidget {
  /// Creates a delivery summary.
  const CheckoutDeliverySummary({required this.selected, super.key});

  /// Shipping method selected on the cart.
  final ShippingMethod? selected;

  @override
  Widget build(BuildContext context) {
    final method = selected;
    if (method == null) return const SizedBox.shrink();
    return FractionallySizedBox(
      widthFactor: 1 / 3,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'shop_checkout_method',
            defaultText: 'Method',
            style: _deliverySummaryTitleStyle,
          ),
          Text(
            method.fulfillmentType == ShippingFulfillmentType.pickup
                ? '${method.pickupName ?? method.name}\n${method.pickupAddress ?? ''}'
                : '${method.name} ${formatMoney(method.amount)}',
            style: _deliverySummaryValueStyle,
          ),
        ],
      ),
    );
  }
}

const _deliverySummaryTitleStyle = TextStyle(
  fontSize: 14,
  height: 20 / 14,
  fontWeight: FontWeight.w600,
);

const _deliverySummaryValueStyle = TextStyle(
  color: StoreColors.foregroundSubtle,
  fontSize: 14,
  height: 20 / 14,
);
