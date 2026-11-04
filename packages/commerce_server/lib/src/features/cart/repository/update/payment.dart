import 'package:dust_dart/db.dart';

part 'payment.g.dart';

/// Atomic writes for the payment provider selected on an active cart.
@SqlxDao()
abstract final class CartPaymentRepository {
  /// Binds payment-session writes to [db].
  const factory CartPaymentRepository(Executor db) = _$CartPaymentRepository;

  /// Retains one enabled regional provider choice while the cart is active.
  @Query(r'''
INSERT INTO cart_payment_sessions (cart_id, provider_id)
SELECT carts.id, region_payment_providers.provider_id
FROM carts
JOIN region_payment_providers
  ON region_payment_providers.region_id = carts.region_id
 AND region_payment_providers.provider_id = $2
 AND region_payment_providers.enabled = 1
WHERE carts.id = $1
  AND carts.completed_at IS NULL
  AND carts.deleted_at IS NULL
ON CONFLICT (cart_id) DO UPDATE SET provider_id = excluded.provider_id
''')
  Future<Result<ExecResult, SqlxError>> setPaymentSession(
    String cartId,
    String providerId,
  );
}
