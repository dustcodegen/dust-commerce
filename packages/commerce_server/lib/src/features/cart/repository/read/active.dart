import 'package:dust_dart/db.dart';

part 'active.g.dart';

/// The active-cart capability read.
@SqlxDao()
abstract final class CartActivityRepository {
  /// Binds the query to [db].
  const factory CartActivityRepository(Executor db) = _$CartActivityRepository;

  /// Returns a row only while the cart can still be mutated or resumed.
  @Query(r'''
SELECT 1
FROM carts
WHERE id = $1 AND completed_at IS NULL AND deleted_at IS NULL
''')
  Future<Result<int?, SqlxError>> active(String cartId);
}
