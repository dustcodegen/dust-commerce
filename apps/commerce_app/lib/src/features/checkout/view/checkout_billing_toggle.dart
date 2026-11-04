import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source-spaced control for reusing the shipping destination for billing.
final class CheckoutBillingToggle extends StatelessWidget {
  /// Creates the billing-address toggle.
  const CheckoutBillingToggle({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Receives the next checked state.
  final ValueChanged<bool> onChanged;

  /// Whether the shipping destination is reused.
  final bool value;

  @override
  Widget build(BuildContext context) {
    final label = context.tr(
      'shop_checkout_same_billing',
      defaultText: 'Billing address same as shipping address',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Semantics(
        checked: value,
        label: label,
        child: InkWell(
          onTap: () => onChanged(!value),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 16,
                child: Checkbox(
                  value: value,
                  onChanged: (next) => onChanged(next ?? false),
                  activeColor: StoreColors.foreground,
                  checkColor: StoreColors.base,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: StoreColors.borderStrong),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: _billingToggleLabelStyle)),
            ],
          ),
        ),
      ),
    );
  }
}

const _billingToggleLabelStyle = TextStyle(fontSize: 14, height: 20 / 14);
