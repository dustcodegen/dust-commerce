import 'package:dust_dart/serde.dart';

part 'account.g.dart';

/// Email/password credentials accepted by the customer auth provider.
@Derive([Serialize(), Deserialize(), Validate()])
final class Credentials with _$Credentials {
  /// Creates credentials.
  const Credentials({required this.email, required this.password});

  /// Decodes JSON using Dust after trimming the email boundary.
  factory Credentials.fromJson(Map<String, Object?> json) =>
      _$CredentialsFromJson(_trimEmail(json));

  /// Customer sign-in email.
  @Validate(length: Length(min: 3, max: 254), message: 'Enter a valid email')
  @Validate(email: true, message: 'Enter a valid email')
  final String email;

  /// Plaintext password accepted only at the request boundary.
  @Validate(
    length: Length(min: 12, max: 1024),
    message: 'Use 12 to 1024 characters',
  )
  final String password;
}

/// The body accepted when a customer creates an account.
@Derive([Serialize(), Deserialize(), Validate()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class RegisterAccountBody with _$RegisterAccountBody {
  /// Creates a registration body.
  const RegisterAccountBody({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.phone,
  });

  /// Decodes JSON using Dust after trimming the email boundary.
  factory RegisterAccountBody.fromJson(Map<String, Object?> json) =>
      _$RegisterAccountBodyFromJson(_trimEmail(json));

  /// Customer email, normalized before persistence.
  @Validate(length: Length(min: 3, max: 254), message: 'Enter a valid email')
  @Validate(email: true, message: 'Enter a valid email')
  final String email;

  /// Optional customer first name.
  @Validate(
    length: Length(min: 1, max: 100),
    message: 'Use 1 to 100 characters',
  )
  final String? firstName;

  /// Optional customer last name.
  @Validate(
    length: Length(min: 1, max: 100),
    message: 'Use 1 to 100 characters',
  )
  final String? lastName;

  /// Plaintext password accepted only at the request boundary.
  @Validate(
    length: Length(min: 12, max: 1024),
    message: 'Use 12 to 1024 characters',
  )
  final String password;

  /// Optional customer phone number.
  @Validate(length: Length(max: 50), message: 'Use at most 50 characters')
  final String? phone;
}

/// A newly issued bearer token, shown exactly once.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class IssuedToken with _$IssuedToken {
  /// Creates a token response.
  const IssuedToken({required this.token, required this.expiresAt});

  /// Decodes JSON using Dust.
  factory IssuedToken.fromJson(Map<String, Object?> json) =>
      _$IssuedTokenFromJson(json);

  /// Session expiry instant.
  final DateTime expiresAt;

  /// Opaque bearer token returned once; only its fingerprint is stored.
  final String token;
}

/// Single-use capability accepted from an email verification link.
@Derive([Serialize(), Deserialize(), Validate()])
final class VerifyEmailBody with _$VerifyEmailBody {
  /// Creates a verification request.
  const VerifyEmailBody({required this.token});

  /// Decodes JSON using Dust.
  factory VerifyEmailBody.fromJson(Map<String, Object?> json) =>
      _$VerifyEmailBodyFromJson(json);

  /// Opaque capability sent only in the email link and confirmation body.
  @Validate(length: Length(min: 32, max: 1024), message: 'Invalid token')
  final String token;
}

/// Confirms that one email capability was consumed.
@Derive([Serialize(), Deserialize()])
final class EmailVerified with _$EmailVerified {
  /// Creates a verification response.
  const EmailVerified({required this.success});

  /// Decodes JSON using Dust.
  factory EmailVerified.fromJson(Map<String, Object?> json) =>
      _$EmailVerifiedFromJson(json);

  /// Whether the account email is now verified.
  final bool success;
}

/// Confirms that the current session token was revoked.
@Derive([Serialize(), Deserialize()])
final class SessionDeleted with _$SessionDeleted {
  /// Creates a session-deletion response.
  const SessionDeleted({required this.success});

  /// Decodes JSON using Dust.
  factory SessionDeleted.fromJson(Map<String, Object?> json) =>
      _$SessionDeletedFromJson(json);

  /// Whether the session is no longer usable.
  final bool success;
}

Map<String, Object?> _trimEmail(Map<String, Object?> json) {
  final email = json['email'];
  return email is String ? {...json, 'email': email.trim()} : json;
}
