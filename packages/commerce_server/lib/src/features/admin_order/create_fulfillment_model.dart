import 'package:dust_dart/db.dart';

part 'create_fulfillment_model.g.dart';

/// Validated provider configuration for one shipping option and location.
@Derive([FromRow()])
final class AdminFulfillmentContext {
  /// Creates the direct SQLx context projection.
  const AdminFulfillmentContext({required this.providerId, required this.data});

  /// Provider-private option payload copied into the fulfillment snapshot.
  final String? data;

  /// Active provider shared by the option and stock location.
  @Sqlx(rename: 'provider_id')
  final String providerId;
}

/// One validated order-line snapshot and currently fulfillable quantity.
@Derive([FromRow()])
final class AdminFulfillmentLine {
  /// Creates the direct SQLx order-line projection.
  const AdminFulfillmentLine({
    required this.title,
    required this.sku,
    required this.barcode,
    required this.remaining,
  });

  /// Provider barcode snapshot; empty when the variant has none.
  final String barcode;

  /// Units not already assigned to an active fulfillment.
  final int remaining;

  /// Provider SKU snapshot; empty when the variant has none.
  final String sku;

  /// Provider-facing order-time title.
  final String title;
}
