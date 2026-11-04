import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// Direct credential-query response used only for password verification.
///
/// It deliberately derives no serializer: a type containing a password hash
/// must never become an HTTP response by accident.
@Derive([Eq(), FromRow()])
final class PasswordCredential with _$PasswordCredential {
  /// Creates a credential query response.
  const PasswordCredential({
    required this.authIdentityId,
    required this.passwordHash,
    required this.requiresEmailVerification,
  });

  /// Medusa-style authentication identity owning this provider credential.
  @Sqlx(rename: 'auth_identity_id')
  final String authIdentityId;

  /// Argon2id PHC string; never returned by an HTTP handler.
  @Sqlx(rename: 'password_hash')
  final String passwordHash;

  /// Whether this identity owns an unfinished verification record.
  @Sqlx(rename: 'requires_email_verification')
  final bool requiresEmailVerification;
}

/// Explicit customer response populated directly from a customer row.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CustomerResponse with _$CustomerResponse {
  /// Constructs the allowlisted customer response.
  const CustomerResponse({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
  });

  /// Email used for account communication and sign-in.
  final String email;

  /// Optional given name from the customer profile.
  @Sqlx(rename: 'first_name')
  final String? firstName;

  /// Stable customer identifier.
  final String id;

  /// Optional family name from the customer profile.
  @Sqlx(rename: 'last_name')
  final String? lastName;

  /// Optional customer contact number.
  final String? phone;
}

/// Explicit address-book response populated directly from an owned row.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CustomerAddressResponse with _$CustomerAddressResponse {
  /// Creates an explicitly allowlisted customer address.
  const CustomerAddressResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.line1,
    required this.city,
    required this.postalCode,
    required this.countryCode,
    required this.isDefaultShipping,
    required this.isDefaultBilling,
    this.company,
    this.line2,
    this.province,
    this.phone,
  });

  /// Primary street address.
  @Sqlx(rename: 'address_1')
  @SerDe(rename: 'address_1')
  final String line1;

  /// Apartment, suite, or unit.
  @Sqlx(rename: 'address_2')
  @SerDe(rename: 'address_2')
  final String? line2;

  /// City or locality.
  final String city;

  /// Optional company or organization.
  final String? company;

  /// Lowercase ISO 3166-1 alpha-2 code.
  @Sqlx(rename: 'country_code')
  final String countryCode;

  /// Recipient given name.
  @Sqlx(rename: 'first_name')
  final String firstName;

  /// Stable address identifier.
  final String id;

  /// Whether this is the customer's default billing address.
  @Sqlx(rename: 'is_default_billing')
  final bool isDefaultBilling;

  /// Whether this is the customer's default shipping address.
  @Sqlx(rename: 'is_default_shipping')
  final bool isDefaultShipping;

  /// Recipient family name.
  @Sqlx(rename: 'last_name')
  final String lastName;

  /// Optional courier contact number.
  final String? phone;

  /// Postal or ZIP code.
  @Sqlx(rename: 'postal_code')
  final String postalCode;

  /// State, province, or region.
  final String? province;
}

/// Explicit response envelope for one customer's active address book.
@Derive([Serialize()])
final class CustomerAddressListResponse with _$CustomerAddressListResponse {
  /// Creates an address listing.
  const CustomerAddressListResponse({
    required this.addresses,
    required this.count,
  });

  /// Active owned addresses.
  final List<CustomerAddressResponse> addresses;

  /// Number of active addresses.
  final int count;
}
