import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/derive.dart';

part 'order_return_request_state.g.dart';

/// Lifecycle of one customer return request form.
enum OrderReturnRequestStatus {
  /// No order owns the form.
  idle,

  /// An eligible paid order is ready for item selection.
  ready,

  /// The request is in flight and duplicate submission is disabled.
  submitting,

  /// The server persisted the request.
  succeeded,

  /// Validation, authorization, or transport rejected the request.
  failed,
}

/// Lifecycle of optional merchant-controlled return-reason discovery.
enum OrderReturnReasonStatus {
  /// The form has not requested reasons.
  idle,

  /// One or more reason pages are loading.
  loading,

  /// Discovery completed, including a valid empty result.
  loaded,

  /// Discovery failed without disabling reason-optional submission.
  failed,
}

/// Display-safe reason a return request did not complete.
enum OrderReturnFailure {
  /// No valid order item has been selected.
  invalidSelection,

  /// The customer session is no longer accepted.
  unauthorized,

  /// The order is missing or belongs to another customer.
  unavailable,

  /// The order or selected quantity cannot enter the return lifecycle.
  notEligible,

  /// A network or unexpected server failure may succeed on retry.
  retryable,
}

/// Immutable UI state for selecting and submitting one return request.
@Derive([ToString(), Eq(), CopyWith()])
final class OrderReturnRequestState with _$OrderReturnRequestState {
  /// Creates an empty return-request state.
  const OrderReturnRequestState({
    this.status = OrderReturnRequestStatus.idle,
    this.expanded = false,
    this.orderId = const None(),
    this.availableQuantities = const {},
    this.quantities = const {},
    this.reasonIds = const {},
    this.reasons = const [],
    this.reasonStatus = OrderReturnReasonStatus.idle,
    this.note = const None(),
    this.request = const None(),
    this.failure = const None(),
  });

  /// Maximum currently returnable quantity keyed by immutable order-item id.
  final Map<String, int> availableQuantities;

  /// Whether the source-shaped help link has expanded the request form.
  final bool expanded;

  /// Display-safe failure for the latest attempt.
  final Option<OrderReturnFailure> failure;

  /// Trimmed optional customer context.
  final Option<String> note;

  /// Authenticated order currently owning the form.
  final Option<String> orderId;

  /// Selected quantity keyed by immutable order-item id.
  final Map<String, int> quantities;

  /// Selected active reason id keyed by immutable order-item id.
  final Map<String, String> reasonIds;

  /// Active merchant-controlled reasons in stable taxonomy order.
  final List<ReturnReasonView> reasons;

  /// Current reason-discovery lifecycle.
  final OrderReturnReasonStatus reasonStatus;

  /// Persisted acknowledgement returned by the Store API.
  final Option<OrderReturnView> request;

  /// Current request lifecycle.
  final OrderReturnRequestStatus status;

  /// Total units selected across all order items.
  int get itemQuantity =>
      quantities.values.fold(0, (total, quantity) => total + quantity);
}
