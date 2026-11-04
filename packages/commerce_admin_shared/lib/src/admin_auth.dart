import 'package:dust_dart/serde.dart';

part 'admin_auth.g.dart';

/// Email/password values accepted only by the admin auth endpoint.
@Derive([Serialize(), Deserialize(), Validate()])
final class AdminCredentials with _$AdminCredentials {
  /// Creates admin credentials.
  const AdminCredentials({required this.email, required this.password});

  /// Decodes JSON using the generated Dust serializer.
  factory AdminCredentials.fromJson(Map<String, Object?> json) =>
      _$AdminCredentialsFromJson(json);

  /// Admin sign-in email.
  @Validate(length: Length(min: 3, max: 254), message: 'Enter a valid email')
  @Validate(email: true, message: 'Enter a valid email')
  @SerDe(using: _TrimmedStringCodec())
  final String email;

  /// Plaintext secret accepted only at the request boundary.
  @Validate(
    length: Length(min: 12, max: 1024),
    message: 'Use 12 to 1024 characters',
  )
  final String password;
}

final class _TrimmedStringCodec implements SerDeCodec<String, String> {
  const _TrimmedStringCodec();

  @override
  String deserialize(String value) => value.trim();

  @override
  String serialize(String value) => value.trim();
}

/// Newly issued admin bearer returned exactly once.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminIssuedToken with _$AdminIssuedToken {
  /// Creates a token response.
  const AdminIssuedToken({required this.token, required this.expiresAt});

  /// Decodes JSON using Dust.
  factory AdminIssuedToken.fromJson(Map<String, Object?> json) =>
      _$AdminIssuedTokenFromJson(json);

  /// UTC ISO-8601 expiry instant.
  final DateTime expiresAt;

  /// Opaque bearer; persistence receives only its fingerprint.
  final String token;
}

/// Confirms that one admin session bearer was revoked.
@Derive([Serialize(), Deserialize()])
final class AdminSessionDeleted with _$AdminSessionDeleted {
  /// Creates the session-deletion response.
  const AdminSessionDeleted({required this.success});

  /// Decodes JSON using Dust.
  factory AdminSessionDeleted.fromJson(Map<String, Object?> json) =>
      _$AdminSessionDeletedFromJson(json);

  /// Whether the bearer is no longer usable.
  final bool success;
}
