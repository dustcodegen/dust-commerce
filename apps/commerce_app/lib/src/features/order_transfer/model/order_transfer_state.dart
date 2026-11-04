import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/derive.dart';

part 'order_transfer_state.g.dart';

/// Order-transfer action selected by the customer or existing order contact.
enum OrderTransferAction {
  /// Ask the existing order contact to review a transfer.
  request,

  /// Move the order to the requesting customer.
  accept,

  /// Keep the order with its current owner.
  decline,
}

/// Lifecycle of the active transfer action.
enum OrderTransferActionStatus {
  /// No action has started on this screen.
  idle,

  /// One request is in flight and duplicate actions are disabled.
  pending,

  /// The server accepted the action.
  succeeded,

  /// The server rejected the action or could not be reached.
  failed,
}

/// Display-safe transfer failures without server or capability details.
enum OrderTransferFailure {
  /// The submitted request is incomplete or cannot be accepted.
  invalidRequest,

  /// The authenticated session is no longer accepted.
  unauthorized,

  /// The order, transfer, or capability is unavailable.
  unavailable,

  /// The order changed after the request and can no longer move owners.
  orderUnavailable,

  /// A competing or opposite transfer decision already exists.
  conflict,

  /// Outbound transfer email is not configured on the server.
  deliveryUnavailable,

  /// A network or unexpected service failure may succeed on retry.
  retryable,
}

/// Public transfer UI state; the emailed capability is never stored here.
@Derive([ToString(), Eq(), CopyWith()])
final class OrderTransferState with _$OrderTransferState {
  /// Creates an empty or completed transfer state.
  const OrderTransferState({
    this.status = OrderTransferActionStatus.idle,
    this.action = const None(),
    this.orderId = const None(),
    this.deliveryStatus = const None(),
    this.failure = const None(),
  });

  /// Active or last completed action.
  final Option<OrderTransferAction> action;

  /// Email-delivery state returned after a transfer request.
  final Option<OrderTransferDeliveryStatus> deliveryStatus;

  /// Classified display failure, when present.
  final Option<OrderTransferFailure> failure;

  /// Normalized order id involved in the action.
  final Option<String> orderId;

  /// Current action lifecycle.
  final OrderTransferActionStatus status;
}
