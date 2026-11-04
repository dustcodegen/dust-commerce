import 'package:dust_dart/serde.dart';

part 'password.g.dart';

/// Password rotation input accepted only at the authenticated API boundary.
@Derive([Serialize(), Deserialize(), Validate()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ChangePasswordBody with _$ChangePasswordBody {
  /// Creates an old/new password pair without trimming either secret.
  const ChangePasswordBody({
    required this.oldPassword,
    required this.newPassword,
  });

  /// Decodes password rotation input using Dust.
  factory ChangePasswordBody.fromJson(Map<String, Object?> json) =>
      _$ChangePasswordBodyFromJson(json);

  /// Replacement plaintext secret, retained only for this request.
  @Validate(
    length: Length(min: 12, max: 1024),
    message: 'Use 12 to 1024 characters',
  )
  final String newPassword;

  /// Current plaintext secret used for reauthentication.
  @Validate(
    length: Length(min: 12, max: 1024),
    message: 'Use 12 to 1024 characters',
  )
  final String oldPassword;
}

/// Explicit response confirming server-side password rotation.
@Derive([Serialize(), Deserialize()])
final class PasswordChanged with _$PasswordChanged {
  /// Creates a password-rotation acknowledgement.
  const PasswordChanged({required this.success});

  /// Decodes the acknowledgement using Dust.
  factory PasswordChanged.fromJson(Map<String, Object?> json) =>
      _$PasswordChangedFromJson(json);

  /// Whether the password was replaced and all prior sessions were revoked.
  final bool success;
}
