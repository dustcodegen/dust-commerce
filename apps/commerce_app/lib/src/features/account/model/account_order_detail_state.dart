import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/derive.dart';

part 'account_order_detail_state.g.dart';

/// Lifecycle of one authenticated customer order request.
enum AccountOrderDetailStatus {
  /// No order has been requested.
  idle,

  /// The selected order is being loaded.
  loading,

  /// The selected order is ready.
  ready,

  /// The order was unavailable or could not be loaded.
  failed,
}

/// Display decision for a failed order-detail request.
enum AccountOrderDetailFailure {
  /// The bearer is no longer accepted.
  sessionExpired,

  /// No order exists for this id and authenticated owner.
  unavailable,

  /// A transient or unknown failure may succeed on retry.
  retryable,
}

/// Customer-owned order-detail state without nullable absence sentinels.
@Derive([ToString(), Eq(), CopyWith()])
final class AccountOrderDetailState with _$AccountOrderDetailState {
  /// Creates an empty or populated detail state.
  const AccountOrderDetailState({
    this.status = AccountOrderDetailStatus.idle,
    this.order = const None(),
    this.failure = const None(),
  });

  /// Classified loading failure, when present.
  final Option<AccountOrderDetailFailure> failure;

  /// Frozen order proven to belong to the active customer.
  final Option<Order> order;

  /// Current request lifecycle.
  final AccountOrderDetailStatus status;
}
