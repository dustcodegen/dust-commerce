part of 'cart.dart';

/// Pricing and immutable line operations for a validated [Cart].
extension CartOperations on Cart {
  /// Whether this cart holds nothing.
  bool get isEmpty => items.isEmpty;

  /// The number of units across every line, which is what a badge shows.
  int get itemCount => items.fold(0, (count, item) => count + item.quantity);

  /// The sum of every line, before tax.
  Money get subtotal => items.fold(
        Money.zero(region.currencyCode),
        (running, item) => running + item.subtotal,
      );

  /// What has actually been taken off the goods.
  ///
  /// A discount worth more than the cart holds is capped at the cart. Handing
  /// back the difference as a negative total would be paying the customer to
  /// shop, and the shipping is a cost the courier charges regardless — so a
  /// discount reduces the goods and stops there.
  Money get discountTotal {
    final asked = promotions.fold(
      Money.zero(region.currencyCode),
      (total, promotion) => total + promotion.amount,
    );
    return asked > subtotal ? subtotal : asked;
  }

  /// What delivery adds.
  Money get shippingTotal =>
      shippingMethod?.amount ?? Money.zero(region.currencyCode);

  /// The amount tax is worked out on: goods plus shipping, less the discount.
  ///
  /// Shipping is taxed with the goods, which is what most jurisdictions do and
  /// what Medusa does. The discount comes off before tax rather than after, so
  /// a customer is not taxed on money they did not pay.
  Money get taxableTotal => subtotal + shippingTotal - discountTotal;

  /// The tax on [taxableTotal], under the region's rule.
  Money get tax => region.taxOn(taxableTotal);

  /// What the customer pays.
  Money get total => region.withTax(taxableTotal);

  /// This cart with [line] added.
  ///
  /// A line for a variant already present merges into it, keeping the earlier
  /// line's id and price snapshot. Adding the same variant twice is one
  /// customer intending one line at a higher quantity, and the price they
  /// first saw is the one they are held to.
  Cart withLine(LineItem line) {
    final existing =
        items.where((item) => item.variantId == line.variantId).firstOrNull;
    if (existing == null) {
      return copyWith(items: [...items, line]);
    }
    final merged = existing.withQuantity(existing.quantity + line.quantity);
    return copyWith(
      items: [
        for (final item in items) item.id == existing.id ? merged : item,
      ],
    );
  }

  /// This cart without the line identified by [lineId].
  Cart withoutLine(String lineId) => copyWith(
        items: items.where((item) => item.id != lineId).toList(),
      );
}
