import 'package:dust_dart/serde.dart';

part 'admin_create_refund_reason.g.dart';

/// Merchant input for one refund reason.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateRefundReason with _$AdminCreateRefundReason {
  /// Creates one reason definition.
  const AdminCreateRefundReason({
    required this.label,
    required this.code,
    required this.descriptionValue,
  });

  /// Decodes one generated Admin request.
  factory AdminCreateRefundReason.fromJson(Map<String, Object?> json) =>
      _$AdminCreateRefundReasonFromJson(json);

  /// Stable machine code.
  @Validate(length: Length(min: 1, max: 255), message: 'Enter a reason code')
  @Validate(
      regex: r'^[a-z0-9_-]+$',
      message: 'Use lowercase letters, numbers, _ or -')
  final String code;

  /// Optional merchant guidance.
  @SerDe(rename: 'description')
  @Validate(length: Length(max: 1000), message: 'Use at most 1000 characters')
  final String? descriptionValue;

  /// Merchant-facing label.
  @Validate(length: Length(min: 1, max: 255), message: 'Enter a reason label')
  final String label;
}
