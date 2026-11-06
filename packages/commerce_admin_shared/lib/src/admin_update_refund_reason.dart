import 'package:dust_dart/serde.dart';

part 'admin_update_refund_reason.g.dart';

/// Complete editable fields for one refund reason.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateRefundReason with _$AdminUpdateRefundReason {
  /// Creates one reason replacement.
  const AdminUpdateRefundReason({
    required this.label,
    required this.code,
    required this.descriptionValue,
  });

  /// Decodes one generated Admin request.
  factory AdminUpdateRefundReason.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateRefundReasonFromJson(json);

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
