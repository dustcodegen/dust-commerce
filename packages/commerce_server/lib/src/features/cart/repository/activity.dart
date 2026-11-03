import 'package:dust_dart/db.dart';

part 'activity.g.dart';

/// The minimal cart-state read used by the public capability guard.
@SqlxDao()
abstract final class CartActivityRepository {
  /// Binds the queries to [db].
  const factory CartActivityRepository(Executor db) = _$CartActivityRepository;

  /// Returns a row only while the cart can still be mutated or resumed.
  @Query(r'''
SELECT 1
FROM carts
WHERE id = $1 AND completed_at IS NULL AND deleted_at IS NULL
''')
  Future<Result<int?, SqlxError>> active(String cartId);
}
