import 'package:commerce_server/src/features/account/model.dart';
import 'package:dust_dart/db.dart';

part 'create.g.dart';

/// Writes for customer registration and session creation.
@SqlxDao()
abstract final class AccountCreateRepository {
  /// Binds the queries to [db].
  const factory AccountCreateRepository(Executor db) =
      _$AccountCreateRepository;

  /// Creates the customer actor. A uniqueness race becomes zero rows.
  @Query(r'''
INSERT INTO customers (id, email, first_name, last_name, phone, has_account)
VALUES ($1, $2, $3, $4, $5, 1)
ON CONFLICT DO NOTHING
''')
  Future<Result<ExecResult, SqlxError>> insertCustomer(
    String id,
    String email,
    String? firstName,
    String? lastName,
    String? phone,
  );

  /// Creates the provider-independent auth identity.
  @Query(r'''
INSERT INTO auth_identity (id, app_metadata) VALUES ($1, $2)
''')
  Future<Result<ExecResult, SqlxError>> insertAuthIdentity(
    String id,
    String appMetadata,
  );

  /// Attaches the email/password provider and its Argon2id PHC value.
  @Query(r'''
INSERT INTO provider_identity
  (id, entity_id, provider, auth_identity_id, provider_metadata)
VALUES ($1, $2, 'emailpass', $3, $4)
''')
  Future<Result<ExecResult, SqlxError>> insertProviderIdentity(
    String id,
    String email,
    String authIdentityId,
    String providerMetadata,
  );

  /// Stores only an opaque token's fingerprint.
  @Query(r'''
INSERT INTO auth_tokens (token_hash, auth_identity_id, expires_at)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insertToken(
    String tokenHash,
    String authIdentityId,
    String expiresAt,
  );

  /// Requires a new identity to consume one emailed capability before sign-in.
  @Query(r'''
INSERT INTO email_verifications (auth_identity_id, token_hash, expires_at)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insertEmailVerification(
    String authIdentityId,
    String tokenHash,
    String expiresAt,
  );

  /// Creates one customer-owned reusable address and returns its public row.
  @Query(r'''
INSERT INTO customer_addresses
  (id, customer_id, first_name, last_name, company, phone, address_1,
   address_2, city, province, postal_code, country_code,
   is_default_shipping, is_default_billing)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
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
  Future<Result<CustomerAddressResponse, SqlxError>> insertAddress(
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
