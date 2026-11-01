import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:dust_dart/db.dart';

part 'create_repository.g.dart';

/// Direct SQLx persistence for merchant-created customer profiles.
@SqlxDao()
abstract final class AdminCustomerCreateRepository {
  /// Binds customer creation to [db].
  const factory AdminCustomerCreateRepository(Executor db) =
      _$AdminCustomerCreateRepository;

  /// Inserts one guest profile unless that active guest email already exists.
  @Query(r'''
INSERT INTO customers (
  id, email, company_name, first_name, last_name, phone, has_account
)
SELECT $1, $2, $3, $4, $5, $6, 0
WHERE NOT EXISTS (
  SELECT 1 FROM customers
  WHERE email = $2 AND has_account = 0 AND deleted_at IS NULL
)
RETURNING id,
          email,
          company_name,
          first_name,
          last_name,
          phone,
          has_account,
          created_at,
          updated_at,
          '[]' AS addresses_json
''')
  Future<Result<AdminCustomerDetailResponse?, SqlxError>> insert(
    String id,
    String email,
    String? companyName,
    String? firstName,
    String? lastName,
    String? phone,
  );
}
