import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';

/// Source-shaped progress toward a conditional zero-cost delivery option.
final class FreeShippingProgress {
  /// Creates immutable display progress from server-owned amounts.
  const FreeShippingProgress({
    required this.remaining,
    required this.fraction,
    required this.targetReached,
  });

  /// Progress bar width, clamped to its visible track.
  final double fraction;

  /// Amount still needed to satisfy the minimum.
  final Money remaining;

  /// Whether the zero-cost option is already available.
  final bool targetReached;
}

/// Finds the first Medusa-shaped free-shipping minimum for [cart].
Option<FreeShippingProgress> freeShippingProgressOf(
  CartView cart,
  List<ShippingOption> options,
) {
  for (final option in options) {
    if (option.amount.amount != 0 ||
        option.amount.currencyCode != cart.subtotal.currencyCode) {
      continue;
    }
    for (final rule in option.priceRules) {
      if (rule.attribute != ShippingPriceRuleAttribute.itemTotal) continue;
      final current = cart.subtotal.amount;
      final target = rule.value;
      final reached = switch (rule.operator) {
        ShippingPriceRuleOperator.gt => current > target,
        ShippingPriceRuleOperator.gte => current >= target,
        ShippingPriceRuleOperator.lt => current < target,
        ShippingPriceRuleOperator.lte => current <= target,
        ShippingPriceRuleOperator.eq => current == target,
      };
      final remaining = switch (rule.operator) {
        ShippingPriceRuleOperator.gt => reached ? 0 : target + 1 - current,
        ShippingPriceRuleOperator.gte => reached ? 0 : target - current,
        ShippingPriceRuleOperator.lt => reached ? 0 : current + 1 - target,
        ShippingPriceRuleOperator.lte => reached ? 0 : current - target,
        ShippingPriceRuleOperator.eq => (current - target).abs(),
      };
      final fraction = target == 0
          ? (reached ? 1.0 : 0.0)
          : (current / target).clamp(0.0, 1.0);
      return Some(FreeShippingProgress(
        remaining: Money.of(remaining, cart.subtotal.currencyCode),
        fraction: fraction,
        targetReached: reached,
      ));
    }
  }
  return const None<FreeShippingProgress>();
}
