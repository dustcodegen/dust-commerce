import 'package:dust_dart/serde.dart';

part 'region_policy.g.dart';

/// Store-owned regional shipping and return policy values.
///
/// This is an explicit public allowlist for the Medusa region metadata keys;
/// arbitrary merchant metadata never crosses the storefront boundary.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class StoreRegionPolicy with _$StoreRegionPolicy {
  /// Creates a validated regional policy.
  const StoreRegionPolicy({
    required this.freeReturns,
    required this.handlingDaysMax,
    required this.handlingDaysMin,
    required this.returnWindowDays,
    required this.shippingRate,
    required this.transitDaysMax,
    required this.transitDaysMin,
  });

  /// Decodes the explicit public policy response.
  factory StoreRegionPolicy.fromJson(Map<String, Object?> json) =>
      _$StoreRegionPolicyFromJson(json);

  /// Reads only the current Medusa policy keys from region metadata.
  static StoreRegionPolicy? fromMetadata(Map<String, Object?> metadata) {
    final returnWindowDays = _nonNegativeInt(metadata['return_window_days']);
    final handlingDaysMin = _nonNegativeInt(metadata['handling_days_min']);
    final handlingDaysMax = _nonNegativeInt(metadata['handling_days_max']);
    final transitDaysMin = _nonNegativeInt(metadata['transit_days_min']);
    final transitDaysMax = _nonNegativeInt(metadata['transit_days_max']);
    final shippingRate = _nonNegativeDecimal(metadata['shipping_rate']);
    final freeReturns = _boolean(metadata['free_returns']) ?? false;
    if (returnWindowDays == null ||
        handlingDaysMin == null ||
        handlingDaysMax == null ||
        transitDaysMin == null ||
        transitDaysMax == null ||
        shippingRate == null ||
        handlingDaysMin > handlingDaysMax ||
        transitDaysMin > transitDaysMax) {
      return null;
    }
    return StoreRegionPolicy(
      freeReturns: freeReturns,
      handlingDaysMax: handlingDaysMax,
      handlingDaysMin: handlingDaysMin,
      returnWindowDays: returnWindowDays,
      shippingRate: shippingRate,
      transitDaysMax: transitDaysMax,
      transitDaysMin: transitDaysMin,
    );
  }

  /// Whether return shipping is free.
  final bool freeReturns;

  /// Maximum handling time in business days.
  final int handlingDaysMax;

  /// Minimum handling time in business days.
  final int handlingDaysMin;

  /// Number of days after delivery in which a return is accepted.
  final int returnWindowDays;

  /// Shipping rate in the region's source-policy currency units.
  ///
  /// It remains a validated decimal string so the metadata boundary never
  /// introduces floating-point money into the shared commerce model.
  final String shippingRate;

  /// Maximum transit time in business days.
  final int transitDaysMax;

  /// Minimum transit time in business days.
  final int transitDaysMin;
}

bool? _boolean(Object? value) {
  if (value is bool) return value;
  if (value is String) {
    return switch (value.trim().toLowerCase()) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }
  return null;
}

int? _nonNegativeInt(Object? value) {
  if (value is int) return value >= 0 ? value : null;
  if (value is num && value.isFinite && value >= 0 && value == value.round()) {
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    return parsed != null && parsed >= 0 ? parsed : null;
  }
  return null;
}

String? _nonNegativeDecimal(Object? value) {
  final text = switch (value) {
    String() => value.trim(),
    num() when value.isFinite && value >= 0 => value.toString(),
    _ => null,
  };
  if (text == null || !RegExp(r'^\d+(?:\.\d+)?$').hasMatch(text)) {
    return null;
  }
  final separator = text.indexOf('.');
  if (separator < 0) return text;
  final whole = text.substring(0, separator);
  final fraction =
      text.substring(separator + 1).replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty ? whole : '$whole.$fraction';
}
