import 'package:commerce_server/src/features/order_return/model.dart';
import 'package:dust_dart/db.dart';

part 'list.g.dart';

/// Public return-reason and customer-owned return-history queries.
@SqlxDao()
abstract final class OrderReturnListRepository {
  /// Binds reason discovery to [db].
  const factory OrderReturnListRepository(Executor db) =
      _$OrderReturnListRepository;

  /// Counts every active reason independently from page size.
  @Query(r'''
SELECT count(*)
FROM return_reasons
WHERE deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> countReasons();

  /// Counts active returns only through a proven customer and order pair.
  @Query(r'''
SELECT count(*)
FROM return_requests
WHERE order_id = $1 AND customer_id = $2 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> countForOrder(
    String orderId,
    String customerId,
  );

  /// Lists direct customer-safe return projections newest first.
  @Query(r'''
SELECT request.id, request.display_id, request.order_id, request.status,
       SUM(item.quantity) AS item_quantity, request.requested_at
FROM return_requests request
JOIN return_items item ON item.return_id = request.id
WHERE request.order_id = $1 AND request.customer_id = $2
  AND request.deleted_at IS NULL
GROUP BY request.id, request.display_id, request.order_id,
         request.status, request.requested_at
ORDER BY request.requested_at DESC, request.display_id DESC
LIMIT $3 OFFSET $4
''')
  Future<Result<List<OrderReturnResponse>, SqlxError>> forOrder(
    String orderId,
    String customerId,
    int limit,
    int offset,
  );

  /// Lists active reasons with parents before children in stable groups.
  @Query(r'''
SELECT id, value, label, description, parent_return_reason_id,
       created_at, updated_at
FROM return_reasons
WHERE deleted_at IS NULL
ORDER BY COALESCE(parent_return_reason_id, id),
         CASE WHEN parent_return_reason_id IS NULL THEN 0 ELSE 1 END,
         lower(label), id
LIMIT $1 OFFSET $2
''')
  Future<Result<List<ReturnReasonResponse>, SqlxError>> reasons(
    int limit,
    int offset,
  );
}
