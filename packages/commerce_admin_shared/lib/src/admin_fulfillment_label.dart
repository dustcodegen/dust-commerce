import 'package:dust_dart/serde.dart';

part 'admin_fulfillment_label.g.dart';

/// One merchant-safe carrier label detached from persistence internals.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminFulfillmentLabel with _$AdminFulfillmentLabel {
  /// Creates one explicit Admin fulfillment-label response.
  const AdminFulfillmentLabel({
    required this.id,
    required this.fulfillmentId,
    required this.trackingNumber,
    required this.trackingUrl,
    required this.labelUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes one generated Admin fulfillment-label response.
  factory AdminFulfillmentLabel.fromJson(Map<String, Object?> json) =>
      _$AdminFulfillmentLabelFromJson(json);

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Parent fulfillment identifier.
  final String fulfillmentId;

  /// Stable label identifier.
  final String id;

  /// Printable carrier label URL or safe placeholder.
  final String labelUrl;

  /// Provider tracking identifier.
  final String trackingNumber;

  /// Carrier tracking URL or safe placeholder.
  final String trackingUrl;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}
