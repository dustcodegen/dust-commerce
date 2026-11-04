import 'package:dust_dart/serde.dart';

part 'fulfillment_label_response.g.dart';

/// Merchant-safe fulfillment label decoded inside the direct SQL projection.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminFulfillmentLabelResponse with _$AdminFulfillmentLabelResponse {
  /// Creates one explicit nested fulfillment-label response.
  const AdminFulfillmentLabelResponse({
    required this.id,
    required this.fulfillmentId,
    required this.trackingNumber,
    required this.trackingUrl,
    required this.labelUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes one JSON object selected by SQLite.
  factory AdminFulfillmentLabelResponse.fromJson(Map<String, Object?> json) =>
      _$AdminFulfillmentLabelResponseFromJson(json);

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Parent fulfillment identifier.
  final String fulfillmentId;

  /// Stable carrier-label identifier.
  final String id;

  /// Printable label URL or safe placeholder.
  final String labelUrl;

  /// Carrier tracking identifier.
  final String trackingNumber;

  /// Carrier tracking URL or safe placeholder.
  final String trackingUrl;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}
