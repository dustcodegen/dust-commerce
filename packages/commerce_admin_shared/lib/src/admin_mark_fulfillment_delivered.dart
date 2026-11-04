import 'package:dust_dart/serde.dart';

part 'admin_mark_fulfillment_delivered.g.dart';

/// Input for Medusa's mark-order-fulfillment-as-delivered operation.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminMarkFulfillmentDelivered with _$AdminMarkFulfillmentDelivered {
  /// Creates one explicit delivery command.
  const AdminMarkFulfillmentDelivered({this.noNotification = false});

  /// Decodes the generated Admin delivery request body.
  factory AdminMarkFulfillmentDelivered.fromJson(Map<String, Object?> json) =>
      _$AdminMarkFulfillmentDeliveredFromJson(json);

  /// Whether the customer notification should be suppressed.
  @SerDe(defaultValue: false)
  final bool noNotification;
}
