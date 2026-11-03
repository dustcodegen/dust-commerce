import 'package:commerce_server/src/features/account/model.dart';
import 'package:dust_dart/db.dart';

part 'update.g.dart';

/// Customer profile and owned-address mutations.
@SqlxDao()
abstract final class AccountUpdateRepository {
  /// Binds the queries to [db].
  const factory AccountUpdateRepository(Executor db) =
      _$AccountUpdateRepository;

  /// Consumes one live capability and removes its reusable fingerprint.
  @Query(r'''
UPDATE email_verifications
SET token_hash = NULL,
    verified_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE token_hash = $1 AND verified_at IS NULL AND expires_at > $2
''')
  Future<Result<ExecResult, SqlxError>> confirmEmail(
    String tokenHash,
    String now,
  );

  /// Replaces an expired or lost capability only while verification is pending.
  @Query(r'''
UPDATE email_verifications
SET token_hash = $2, expires_at = $3
WHERE auth_identity_id = $1 AND verified_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> replaceEmailVerification(
    String authIdentityId,
    String tokenHash,
    String expiresAt,
  );

  /// Replaces an unchanged credential hash using compare-and-swap semantics.
  @Query(r'''
UPDATE provider_identity
SET provider_metadata = json_set(
      coalesce(provider_metadata, '{}'), '$.password', $3
    )
WHERE auth_identity_id = $1
  AND provider = 'emailpass'
  AND CAST(json_extract(provider_metadata, '$.password') AS TEXT) = $2
  AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> updatePassword(
    String authIdentityId,
    String expectedHash,
    String newHash,
  );

  /// Replaces editable profile fields for one active customer.
  @Query(r'''
UPDATE customers
SET first_name = $2, last_name = $3, phone = $4
WHERE id = $1 AND has_account = 1 AND deleted_at IS NULL
RETURNING id, coalesce(email, '') AS email, first_name, last_name, phone
''')
  Future<Result<CustomerResponse?, SqlxError>> updateProfile(
    String customerId,
    String firstName,
    String lastName,
    String? phone,
  );

  /// Replaces one active address only when the customer owns it.
  @Query(r'''
UPDATE customer_addresses
SET first_name = $3, last_name = $4, company = $5, phone = $6,
    address_1 = $7, address_2 = $8, city = $9, province = $10,
    postal_code = $11, country_code = $12,
    is_default_shipping = $13, is_default_billing = $14
WHERE id = $1 AND customer_id = $2 AND deleted_at IS NULL
RETURNING id,
          coalesce(first_name, '') AS first_name,
          coalesce(last_name, '') AS last_name,
          company, phone, address_1, address_2,
          coalesce(city, '') AS city,
          province,
          coalesce(postal_code, '') AS postal_code,
          country_code,
          is_default_shipping = 1 AS is_default_shipping,
          is_default_billing = 1 AS is_default_billing
''')
  Future<Result<CustomerAddressResponse?, SqlxError>> updateAddress(
    String id,
    String customerId,
    String firstName,
    String lastName,
    String? company,
    String? phone,
    String line1,
    String? line2,
    String city,
    String? province,
    String postalCode,
    String countryCode,
    int isDefaultShipping,
    int isDefaultBilling,
  );
}
