import 'package:dust_dart/serde.dart';

part 'order_transfer.g.dart';

/// Lifecycle of a request to move an order to another registered customer.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum OrderTransferStatus {
  /// Waiting for the existing order owner to decide.
  requested,

  /// The existing owner approved the new customer.
  accepted,

  /// The existing owner rejected the request.
  declined,

  /// The capability reached its deadline without a decision.
  expired,
}

/// Delivery state of the email containing the owner decision link.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum OrderTransferDeliveryStatus {
  /// Waiting for an SMTP attempt.
  queued,

  /// Temporarily leased by one sender.
  sending,

  /// Accepted by the configured SMTP server.
  sent,

  /// No further delivery is valid for this transfer.
  cancelled,
}

/// Minimal public state of an order-transfer request.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderTransferView with _$OrderTransferView {
  /// Creates a decoded transfer view.
  const OrderTransferView({
    required this.id,
    required this.orderId,
    required this.status,
    required this.deliveryStatus,
    required this.expiresAt,
  });

  /// Creates a transfer view from the server response.
  factory OrderTransferView.fromJson(Map<String, Object?> json) =>
      _$OrderTransferViewFromJson(json);

  /// Whether the email has been accepted by the configured SMTP server.
  final OrderTransferDeliveryStatus deliveryStatus;

  /// UTC deadline for accepting or declining the request.
  final DateTime expiresAt;

  /// Opaque transfer identifier; never the decision capability.
  final String id;

  /// Order awaiting a decision.
  final String orderId;

  /// Current ownership-transfer lifecycle.
  final OrderTransferStatus status;
}

/// Public capability submitted when the existing owner makes a decision.
@Derive([Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderTransferDecisionBody with _$OrderTransferDecisionBody {
  /// Creates a transfer decision request.
  const OrderTransferDecisionBody({required this.token});

  /// Creates a decision body from JSON.
  factory OrderTransferDecisionBody.fromJson(Map<String, Object?> json) =>
      _$OrderTransferDecisionBodyFromJson(json);

  /// Single-use capability delivered to the existing order email.
  @Validate(
    length: Length(min: 1, max: 512),
    message: 'A transfer token is required',
  )
  final String token;
}
