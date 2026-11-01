import 'package:dust_dart/db.dart';

part 'read.g.dart';

/// The reads that find a payment.
@SqlxDao()
abstract final class PaymentReadRepository {
  /// Binds the queries to [db].
  const factory PaymentReadRepository(Executor db) = _$PaymentReadRepository;

  /// The payment on an order, if one has been started.
  @Query(r'''
SELECT id
FROM payment_collections
WHERE order_id = $1
ORDER BY created_at DESC
LIMIT 1
''')
  Future<Result<String?, SqlxError>> forOrder(String orderId);
}
