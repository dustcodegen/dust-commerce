part of 'cart.dart';

/// Authoritative totals calculated from a cart query response.
extension CartResponseTotals on CartResponse {
  /// Currency fixed by the cart's region.
  String get currencyCode => region.currencyCode;

  /// Number of units across every line.
  int get itemCount => items.fold(0, (count, item) => count + item.quantity);

  /// Sum of every line before tax.
  Money get subtotal => items.fold(
        Money.zero(currencyCode),
        (running, item) => running + item.subtotal,
      );

  /// Discount capped at the goods subtotal.
  Money get discountTotal {
    final asked = promotions.fold(
      Money.zero(currencyCode),
      (total, promotion) => total + promotion.amount,
    );
    return asked > subtotal ? subtotal : asked;
  }

  /// Selected delivery amount, or zero before selection.
  Money get shippingTotal => shippingMethod?.amount ?? Money.zero(currencyCode);

  /// Tax under the cart region's configured rules.
  Money get tax => region.taxOn(subtotal + shippingTotal - discountTotal);

  /// Final amount the customer will be charged.
  Money get total {
    final taxable = subtotal + shippingTotal - discountTotal;
    return region.taxInclusive ? taxable : taxable + tax;
  }

  /// Whether the cart contains no lines.
  bool get isEmpty => items.isEmpty;
}

/// Derived value for one explicit line response.
extension LineItemResponseTotals on LineItemResponse {
  /// Price for the requested quantity.
  Money get subtotal => unitPrice * quantity;
}

/// Tax calculation fixed by one explicit region response.
extension RegionResponseTax on RegionResponse {
  /// Tax contained in or owed on [price].
  Money taxOn(Money price) {
    final denominator = taxInclusive ? 10000 + taxRate : 10000;
    return Money(
      amount: (price.amount * taxRate + denominator ~/ 2) ~/ denominator,
      currencyCode: currencyCode,
    );
  }
}
