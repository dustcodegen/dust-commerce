import 'package:commerce_shared/src/money.dart';
import 'package:dust_dart/serde.dart';

import 'region_policy.dart';

part 'region.g.dart';

/// A selling territory: one currency, one tax rate, a set of countries.
///
/// A region is what makes a price answerable. The same product costs a
/// different amount, in a different currency, under a different tax rule
/// depending on where the customer is buying from, and the region is where
/// that context lives.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class Region with _$Region {
  /// Creates a [Region] from already-normalised values.
  ///
  /// Prefer [Region.of], which validates. This constructor stays unchecked so
  /// it can be `const` and reachable by the generated deserialiser.
  const Region({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.taxRate,
    required this.countries,
    this.policy,
    this.taxInclusive = false,
  });

  /// Creates a [Region], validating and normalising its codes.
  ///
  /// [taxRate] is in basis points: 2000 is 20%. Throws [ArgumentError] when
  /// the rate is outside 0–10000, when a country code is not two letters, or
  /// when [countries] is empty.
  factory Region.of({
    required String id,
    required String name,
    required String currencyCode,
    required int taxRate,
    required List<String> countries,
    StoreRegionPolicy? policy,
    bool taxInclusive = false,
  }) {
    if (taxRate < 0 || taxRate > _hundredPercent) {
      throw ArgumentError.value(
        taxRate,
        'taxRate',
        'expected basis points between 0 and $_hundredPercent',
      );
    }
    if (countries.isEmpty) {
      throw ArgumentError.value(
        countries,
        'countries',
        'a region must serve at least one country',
      );
    }
    return Region(
      id: id,
      name: name,
      currencyCode: Money.of(0, currencyCode).currencyCode,
      taxRate: taxRate,
      countries: countries.map(_country).toList(growable: false),
      policy: policy,
      taxInclusive: taxInclusive,
    );
  }

  /// Creates a [Region] from JSON.
  factory Region.fromJson(Map<String, Object?> json) => _$RegionFromJson(json);

  /// The ISO 3166-1 alpha-2 country codes this region serves, lower case.
  final List<String> countries;

  /// The ISO 4217 alpha-3 currency code of every price in this region.
  final String currencyCode;

  /// Unique identifier.
  final String id;

  /// Display name.
  final String name;

  /// Validated store-owned shipping and return policy, when published.
  final StoreRegionPolicy? policy;

  /// Whether listed prices already contain tax.
  final bool taxInclusive;

  /// The tax rate in basis points: 2000 is 20%.
  final int taxRate;

  /// Whether this region serves [countryCode].
  bool serves(String countryCode) =>
      countries.contains(countryCode.toLowerCase());

  /// The tax contained in, or owed on, [price].
  ///
  /// For a tax-exclusive region this is tax added on top. For a tax-inclusive
  /// region it is the tax already inside the price, which is the portion
  /// remitted rather than an extra charge.
  Money taxOn(Money price) {
    final gross = price.amount;
    if (gross != 0 && price.currencyCode != currencyCode) {
      throw ArgumentError.value(
        price.currencyCode,
        'price',
        'currency mismatch: expected $currencyCode',
      );
    }
    final tax = taxInclusive
        ? _divideHalfUp(gross * taxRate, _hundredPercent + taxRate)
        : _divideHalfUp(gross * taxRate, _hundredPercent);
    return Money(amount: tax, currencyCode: currencyCode);
  }

  /// [price] with tax applied, which is [price] itself when tax is included.
  Money withTax(Money price) => taxInclusive ? price : price + taxOn(price);

  static const int _hundredPercent = 10000;

  static final RegExp _alpha2 = RegExp(r'^[A-Za-z]{2}$');

  static String _country(String code) {
    if (!_alpha2.hasMatch(code)) {
      throw ArgumentError.value(
        code,
        'countries',
        'expected a two-letter ISO 3166-1 code',
      );
    }
    return code.toLowerCase();
  }

  /// Integer division rounding a half away from zero.
  ///
  /// Tax lands on a fraction of a minor unit constantly, and Dart's `~/`
  /// truncates, which quietly under-collects on every line of every order.
  static int _divideHalfUp(int numerator, int denominator) {
    final doubled = numerator.abs() * 2 + denominator;
    final magnitude = doubled ~/ (denominator * 2);
    return numerator.isNegative ? -magnitude : magnitude;
  }
}
