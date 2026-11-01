import 'package:commerce_server/src/features/admin_order/create_fulfillment_model.dart';
import 'package:dust_dart/db.dart';

part 'create_fulfillment_repository.g.dart';

/// Transaction-scoped persistence for Admin fulfillment creation.
@SqlxDao()
abstract final class AdminCreateFulfillmentRepository {
  /// Binds fulfillment validation and writes to [db].
  const factory AdminCreateFulfillmentRepository(Executor db) =
      _$AdminCreateFulfillmentRepository;

  /// Distinguishes an unavailable order from invalid fulfillment selections.
  @Query(r'''
SELECT count(*) FROM orders WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> orderCount(String orderId);

  /// Resolves one active provider shared by the order option and location.
  @Query(r'''
SELECT assignment.fulfillment_provider_id AS provider_id, assignment.data
FROM orders order_row
JOIN shipping_options option
  ON option.id = $3 AND option.region_id = order_row.region_id
  AND option.currency_code = order_row.currency_code
  AND option.deleted_at IS NULL
JOIN shipping_option_fulfillment_provider assignment
  ON assignment.shipping_option_id = option.id
  AND assignment.deleted_at IS NULL
JOIN fulfillment_providers provider
  ON provider.id = assignment.fulfillment_provider_id
  AND provider.deleted_at IS NULL
JOIN stock_locations location
  ON location.id = $2 AND location.deleted_at IS NULL
JOIN stock_location_fulfillment_providers allowed
  ON allowed.stock_location_id = location.id
  AND allowed.fulfillment_provider_id = provider.id
  AND allowed.deleted_at IS NULL
WHERE order_row.id = $1 AND order_row.deleted_at IS NULL
  AND order_row.status <> 'canceled'
''')
  Future<Result<AdminFulfillmentContext?, SqlxError>> context(
    String orderId,
    String locationId,
    String shippingOptionId,
  );

  /// Reads the immutable line snapshot and subtracts active fulfillment units.
  @Query(r'''
SELECT item.title,
       coalesce(variant.sku, '') AS sku,
       coalesce(variant.barcode, '') AS barcode,
       item.quantity - coalesce((
         SELECT sum(fulfilled.quantity)
         FROM fulfillment_items fulfilled
         JOIN fulfillments parent ON parent.id = fulfilled.fulfillment_id
         WHERE fulfilled.line_item_id = item.id
           AND fulfilled.deleted_at IS NULL
           AND parent.deleted_at IS NULL AND parent.canceled_at IS NULL
       ), 0) AS remaining
FROM order_items item
LEFT JOIN product_variants variant ON variant.id = item.variant_id
WHERE item.order_id = $1 AND item.id = $2
''')
  Future<Result<AdminFulfillmentLine?, SqlxError>> line(
    String orderId,
    String lineItemId,
  );

  /// Creates the parent record without application-owned timestamps.
  @Query(r'''
INSERT INTO fulfillments (
  id, order_id, location_id, provider_id, shipping_option_id,
  requires_shipping, created_by, data
) VALUES ($1, $2, $3, $4, $5, 1, $6, $7)
''')
  Future<Result<ExecResult, SqlxError>> insertFulfillment(
    String id,
    String orderId,
    String locationId,
    String providerId,
    String shippingOptionId,
    String createdBy,
    String? data,
  );

  /// Freezes one validated quantity inside the parent fulfillment.
  @Query(r'''
INSERT INTO fulfillment_items (
  id, fulfillment_id, title, quantity, sku, barcode, line_item_id
) VALUES ($1, $2, $3, $4, $5, $6, $7)
''')
  Future<Result<ExecResult, SqlxError>> insertItem(
    String id,
    String fulfillmentId,
    String title,
    int quantity,
    String sku,
    String barcode,
    String lineItemId,
  );
}
