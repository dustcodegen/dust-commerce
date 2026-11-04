import 'package:dust_dart/serde.dart';

part 'admin_user.g.dart';

/// Public profile for a person authorized to operate the admin API.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUser with _$AdminUser {
  /// Creates an allowlisted admin profile.
  const AdminUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
  });

  /// Decodes the admin API response using Dust.
  factory AdminUser.fromJson(Map<String, Object?> json) =>
      _$AdminUserFromJson(json);

  /// Normalized admin sign-in email.
  final String email;

  /// Optional given name for display only.
  final String? firstName;

  /// Stable admin user identifier.
  final String id;

  /// Optional family name for display only.
  final String? lastName;
}
