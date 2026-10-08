import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

/// One labelled amount in the checkout total breakdown.
final class CheckoutTotalRow extends StatelessWidget {
  /// Creates a checkout total row.
  const CheckoutTotalRow({
    required this.label,
    required this.money,
    this.discount = false,
    this.strong = false,
    super.key,
  });

  /// Whether the amount is a subtraction highlighted as a discount.
  final bool discount;

  /// Human-readable total label.
  final String label;

  /// Currency-aware amount to render.
  final Money money;

  /// Whether the row is the emphasized grand total.
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: strong
                    ? StoreColors.foreground
                    : StoreColors.foregroundSubtle,
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
            Text(
              '${discount ? '- ' : ''}${formatMoney(money)}',
              style: TextStyle(
                color: discount
                    ? StoreColors.interactive
                    : strong
                        ? StoreColors.foreground
                        : StoreColors.foregroundSubtle,
                fontSize: strong ? 20 : 14,
                height: strong ? 28 / 20 : 20 / 14,
                fontWeight: strong ? FontWeight.w500 : null,
              ),
            ),
          ],
        ),
      );
}
