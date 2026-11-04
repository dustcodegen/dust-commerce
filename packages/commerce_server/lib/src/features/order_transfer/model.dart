import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// Internal order facts required before a transfer may be requested.
@Derive([FromRow()])
final class OrderTransferCandidate {
  /// Creates candidate facts directly from the order query.
  const OrderTransferCandidate({
    required this.orderId,
    required this.orderStatus,
    this.orderCustomerId,
  });

  /// Existing owner, absent for a guest order.
  @Sqlx(rename: 'customer_id')
  final String? orderCustomerId;

  /// Stable order identifier.
  @Sqlx(rename: 'id')
  final String orderId;

  /// Stored order lifecycle used to reject canceled transfers.
  @Sqlx(rename: 'status')
  final String orderStatus;
}

/// Explicit public transfer allowlist populated directly by SQLx.
@Derive([FromRow(), Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderTransferResponse with _$OrderTransferResponse {
  /// Creates a public transfer response from selected database columns.
  const OrderTransferResponse({
    required this.id,
    required this.orderId,
    required this.status,
    required this.deliveryStatus,
    required this.expiresAt,
  });

  /// Current email-delivery lifecycle.
  @Sqlx(rename: 'delivery_status')
  final String deliveryStatus;

  /// UTC transfer deadline decoded directly from the SQLx row.
  @Sqlx(rename: 'expires_at')
  final DateTime expiresAt;

  /// Opaque transfer identifier, never the decision token.
  final String id;

  /// Order awaiting a decision.
  @Sqlx(rename: 'order_id')
  final String orderId;

  /// Current ownership-transfer lifecycle.
  final String status;
}

/// Private delivery data read only after one sender owns the lease.
@Derive([FromRow()])
final class OrderTransferDelivery {
  /// Creates one leased delivery directly from the database query.
  const OrderTransferDelivery({
    required this.id,
    required this.orderId,
    required this.recipientEmail,
    required this.token,
    required this.expiresAt,
  });

  /// UTC decision deadline decoded directly from the SQLx row.
  @Sqlx(rename: 'expires_at')
  final DateTime expiresAt;

  /// Transfer identifier used to complete or release the lease.
  final String id;

  /// Order named in the customer-facing message.
  @Sqlx(rename: 'order_id')
  final String orderId;

  /// Existing order contact that has authority to decide.
  @Sqlx(rename: 'recipient_email')
  final String recipientEmail;

  /// Raw single-use capability, cleared after SMTP accepts the message.
  final String token;
}

/// Private row used to make accept and decline idempotent.
@Derive([FromRow()])
final class OrderTransferDecisionRow {
  /// Creates decision state directly from its query.
  const OrderTransferDecisionRow({
    required this.id,
    required this.status,
  });

  /// Transfer identifier.
  final String id;

  /// Current transfer lifecycle.
  final String status;
}
