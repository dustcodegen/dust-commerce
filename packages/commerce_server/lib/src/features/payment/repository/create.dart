import 'package:dust_dart/db.dart';

part 'create.g.dart';

/// The write that starts a payment.
@SqlxDao()
abstract final class PaymentCreateRepository {
  /// Binds the queries to [db].
  const factory PaymentCreateRepository(Executor db) =
      _$PaymentCreateRepository;

  /// Authorises [amount] against an order.
  ///
  /// Written as `authorized` rather than `pending`: the manual provider has
  /// nothing to wait for, and a status that no code path ever leaves would be
  /// a lie about what the system does.
  @Query(r'''
INSERT INTO payment_collections (id, order_id, provider, amount,
                                 currency_code, status)
VALUES ($1, $2, $3, $4, $5, 'authorized')
''')
  Future<Result<ExecResult, SqlxError>> authorize(
    String id,
    String orderId,
    String provider,
    int amount,
    String currencyCode,
  );
}
