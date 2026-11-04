import 'package:dust_dart/db.dart';

part 'create.g.dart';

/// SQL inserts for order-transfer requests.
@SqlxDao()
abstract final class OrderTransferCreateRepository {
  /// Binds transfer inserts to [db].
  const factory OrderTransferCreateRepository(Executor db) =
      _$OrderTransferCreateRepository;

  /// Creates a queued request after the service checks active ownership.
  @Query(r'''
INSERT INTO order_transfers (
  id, order_id, customer_id, token_fingerprint, delivery_token, expires_at
)
VALUES ($1, $2, $3, $4, $5, $6)
''')
  Future<Result<ExecResult, SqlxError>> insertTransfer(
    String id,
    String orderId,
    String customerId,
    String tokenFingerprint,
    String deliveryToken,
    String expiresAt,
  );
}
