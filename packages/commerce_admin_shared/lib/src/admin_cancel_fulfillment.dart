import 'package:dust_dart/serde.dart';

part 'admin_cancel_fulfillment.g.dart';

/// Input for Medusa's cancel-order-fulfillment operation.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCancelFulfillment with _$AdminCancelFulfillment {
  /// Creates one explicit fulfillment-cancellation command.
  const AdminCancelFulfillment({this.noNotification = false});

  /// Decodes the generated Admin cancellation request body.
  factory AdminCancelFulfillment.fromJson(Map<String, Object?> json) =>
      _$AdminCancelFulfillmentFromJson(json);

  /// Whether customer notification should be suppressed.
  @SerDe(defaultValue: false)
  final bool noNotification;
}
