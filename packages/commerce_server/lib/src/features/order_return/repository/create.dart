import 'package:dust_dart/db.dart';

part 'create.g.dart';

/// SQL inserts for one validated return request and its items.
@SqlxDao()
abstract final class OrderReturnCreateRepository {
  /// Binds return inserts to [db].
  const factory OrderReturnCreateRepository(Executor db) =
      _$OrderReturnCreateRepository;

  /// Persists the request root after all items pass validation.
  @Query(r'''
INSERT INTO return_requests (id, display_id, order_id, customer_id, note)
SELECT $1, COALESCE(MAX(display_id), 0) + 1, $2, $3, $4
FROM return_requests
''')
  Future<Result<ExecResult, SqlxError>> request(
    String id,
    String orderId,
    String customerId,
    String? note,
  );

  /// Persists one validated item under its request root.
  @Query(r'''
INSERT INTO return_items
  (id, return_id, order_item_id, quantity, reason_id, note)
VALUES ($1, $2, $3, $4, $5, $6)
''')
  Future<Result<ExecResult, SqlxError>> item(
    String id,
    String returnId,
    String orderItemId,
    int quantity,
    String? reasonId,
    String? note,
  );
}
