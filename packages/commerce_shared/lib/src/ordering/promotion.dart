import 'package:commerce_shared/src/money.dart';
import 'package:commerce_shared/src/ordering/line_item.dart';
import 'package:dust_dart/serde.dart';

part 'promotion.g.dart';

/// How a promotion works out what to take off.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum PromotionType {
  /// A share of the subtotal, in basis points.
  percentage,

  /// A flat amount in one currency.
  fixed,
}

/// One promotion already applied to a cart.
///
/// This is deliberately narrower than [Promotion]: a storefront may see the
/// code and customer-facing value, but never redemption limits or validity
/// policy. [amount] is the server's current discount snapshot.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CartPromotion with _$CartPromotion {
  /// Creates one explicit public cart-promotion snapshot.
  const CartPromotion({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.amount,
    this.currencyCode,
  });

  /// Current amount this promotion removes from the cart.
  final Money amount;

  /// Customer-entered promotion code.
  final String code;

  /// Currency of [value] for a fixed promotion.
  final String? currencyCode;

  /// Stable promotion identifier.
  final String id;

  /// How [value] is interpreted.
  final PromotionType type;

  /// Basis points for percentages, or minor units for fixed promotions.
  final int value;

  /// Creates a [CartPromotion] from JSON.
  factory CartPromotion.fromJson(Map<String, Object?> json) =>
      _$CartPromotionFromJson(json);
}

/// A code a customer types to pay less.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class Promotion with _$Promotion {
  /// Creates a [Promotion] from already-validated values.
  const Promotion({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.currencyCode,
    this.startsAt,
    this.endsAt,
    this.usageLimit,
    this.usageCount = 0,
  });

  /// Creates a [Promotion], checking that its value makes sense for its type.
  ///
  /// The code is upper-cased: a customer typing `save10` means `SAVE10`, and
  /// making them match the case of a marketing email is a way to lose sales.
  factory Promotion.of({
    required String id,
    required String code,
    required PromotionType type,
    required int value,
    String? currencyCode,
    DateTime? startsAt,
    DateTime? endsAt,
    int? usageLimit,
    int usageCount = 0,
  }) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'a promotion cannot add cost');
    }
    if (type == PromotionType.percentage && value > _hundredPercent) {
      throw ArgumentError.value(
        value,
        'value',
        'expected basis points between 0 and $_hundredPercent',
      );
    }
    if (type == PromotionType.fixed && currencyCode == null) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'a fixed amount needs a currency to be fixed in',
      );
    }
    return Promotion(
      id: id,
      code: code.toUpperCase(),
      type: type,
      value: value,
      currencyCode: currencyCode?.toLowerCase(),
      startsAt: startsAt,
      endsAt: endsAt,
      usageLimit: usageLimit,
      usageCount: usageCount,
    );
  }

  /// Creates a [Promotion] from JSON.
  factory Promotion.fromJson(Map<String, Object?> json) =>
      _$PromotionFromJson(json);

  /// The code a customer types, upper case.
  final String code;

  /// The currency a fixed amount is in.
  final String? currencyCode;

  /// When it stops working, if it does.
  final DateTime? endsAt;

  /// Unique identifier.
  final String id;

  /// When it starts working, if it does not already.
  final DateTime? startsAt;

  /// Whether it is a share or a flat amount.
  final PromotionType type;

  /// How many times it has been redeemed.
  final int usageCount;

  /// How many times it may be redeemed, if there is a limit.
  final int? usageLimit;

  /// Basis points for a percentage, minor units for a fixed amount.
  final int value;

  /// What this takes off [subtotal].
  ///
  /// Never more than the subtotal: a promotion reduces a bill, it does not
  /// create a refund, and a cart cannot owe the customer money.
  Money discountOn(Money subtotal) {
    final off = switch (type) {
      PromotionType.percentage => Money(
          amount: _divideHalfUp(subtotal.amount * value, _hundredPercent),
          currencyCode: subtotal.currencyCode,
        ),
      PromotionType.fixed => Money.of(value, currencyCode!),
    };
    if (off.currencyCode != subtotal.currencyCode) {
      throw ArgumentError.value(
        off.currencyCode,
        'subtotal',
        'currency mismatch: expected ${subtotal.currencyCode}',
      );
    }
    return off > subtotal ? subtotal : off;
  }

  /// Whether this may be redeemed at [when].
  bool isUsableAt(DateTime when) {
    final starts = startsAt;
    final ends = endsAt;
    final limit = usageLimit;

    if (starts != null && when.isBefore(starts)) return false;
    if (ends != null && !when.isBefore(ends)) return false;
    if (limit != null && usageCount >= limit) return false;
    return true;
  }

  static const int _hundredPercent = 10000;

  static int _divideHalfUp(int numerator, int denominator) {
    final doubled = numerator.abs() * 2 + denominator;
    final magnitude = doubled ~/ (denominator * 2);
    return numerator.isNegative ? -magnitude : magnitude;
  }
}

/// Splits [discount] across [lines] in proportion to what each is worth.
///
/// The parts must equal the whole. Rounding each line independently leaves a
/// remainder — ten per cent off three equal lines of 1000 is 33 each, which is
/// 99 rather than 100 — and a total built from parts that do not sum is a
/// total that will one day disagree with itself on a receipt.
///
/// The remainder goes to the largest line, which is both the least noticeable
/// place to put it and the one most able to absorb it without exceeding what
/// the line is worth.
Map<String, Money> allocateDiscount(Money discount, List<LineItem> lines) {
  if (lines.isEmpty) return const {};

  final currency = discount.currencyCode;
  final total = lines.fold(
    0,
    (running, line) => running + line.subtotal.amount,
  );
  if (total == 0) {
    return {for (final line in lines) line.id: Money.zero(currency)};
  }

  final allocated = <String, int>{};
  var handed = 0;
  for (final line in lines) {
    final share = discount.amount * line.subtotal.amount ~/ total;
    final capped = share > line.subtotal.amount ? line.subtotal.amount : share;
    allocated[line.id] = capped;
    handed += capped;
  }

  var remainder = discount.amount - handed;
  if (remainder > 0) {
    final byValue = [...lines]
      ..sort((a, b) => b.subtotal.amount.compareTo(a.subtotal.amount));
    for (final line in byValue) {
      if (remainder == 0) break;
      final room = line.subtotal.amount - allocated[line.id]!;
      final give = remainder < room ? remainder : room;
      allocated[line.id] = allocated[line.id]! + give;
      remainder -= give;
    }
  }

  return {
    for (final entry in allocated.entries)
      entry.key: Money(amount: entry.value, currencyCode: currency),
  };
}
