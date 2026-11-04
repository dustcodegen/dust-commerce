import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

export 'product_detail_model.dart';
export 'product_list_model.dart';

part 'model.g.dart';

/// Direct credential query result kept outside every HTTP response.
@Derive([Eq(), FromRow()])
final class AdminPasswordCredential with _$AdminPasswordCredential {
  /// Creates the private credential projection.
  const AdminPasswordCredential({
    required this.authIdentityId,
    required this.passwordHash,
  });

  /// Provider-independent identity that owns this credential.
  @Sqlx(rename: 'auth_identity_id')
  final String authIdentityId;

  /// Argon2id PHC value; plaintext never reaches persistence.
  @Sqlx(rename: 'password_hash')
  final String passwordHash;
}

/// Public admin response selected directly from SQL without an ORM model.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUserResponse with _$AdminUserResponse {
  /// Creates the public allowlist.
  const AdminUserResponse({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
  });

  /// Normalized operational email.
  final String email;

  /// Optional given name for display only.
  @Sqlx(rename: 'first_name')
  final String? firstName;

  /// Stable admin user identifier.
  final String id;

  /// Optional family name for display only.
  @Sqlx(rename: 'last_name')
  final String? lastName;
}

/// One active storefront currency selected directly for product creation.
@Derive([FromRow()])
final class AdminProductCurrencyResponse {
  /// Creates the private one-column query projection.
  const AdminProductCurrencyResponse({required this.currencyCode});

  /// Lowercase ISO 4217 code backed by at least one active region.
  @Sqlx(rename: 'currency_code')
  final String currencyCode;
}
