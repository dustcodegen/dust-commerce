import 'package:dust_dart/serde.dart';

part 'account_profile.g.dart';

/// Editable customer fields accepted by the authenticated profile route.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class UpdateCustomerProfileBody with _$UpdateCustomerProfileBody {
  /// Creates a complete profile replacement.
  const UpdateCustomerProfileBody({
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  /// Decodes and normalizes text at the HTTP boundary.
  factory UpdateCustomerProfileBody.fromJson(Map<String, Object?> json) =>
      _$UpdateCustomerProfileBodyFromJson(_normalizedProfile(json));

  /// Customer given name.
  @Validate(length: Length(min: 1, max: 100), message: 'Enter a first name')
  final String firstName;

  /// Customer family name.
  @Validate(length: Length(min: 1, max: 100), message: 'Enter a last name')
  final String lastName;

  /// Optional contact number.
  @Validate(length: Length(max: 50), message: 'Use at most 50 characters')
  final String? phone;
}

Map<String, Object?> _normalizedProfile(Map<String, Object?> json) => {
      ...json,
      for (final key in ['first_name', 'last_name'])
        if (json[key] case final String value) key: value.trim(),
      if (json['phone'] case final String value) 'phone': _optional(value),
    };

String? _optional(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
