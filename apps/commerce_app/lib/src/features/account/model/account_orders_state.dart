import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'account_orders_state.g.dart';

/// Loading state for the authenticated customer's order history.
enum AccountOrdersStatus {
  /// Order history has not been requested.
  idle,

  /// Order history is being loaded.
  loading,

  /// The latest order history is ready.
  ready,

  /// Order history could not be loaded.
  failed,
}

/// Display-safe reasons an order-history request failed.
enum AccountOrdersFailure {
  /// The stored customer session is no longer accepted.
  unauthorized,

  /// The service could not return order history.
  unavailable,
}

/// Customer order-history UI state.
@Derive([ToString(), Eq(), CopyWith()])
class AccountOrdersState with _$AccountOrdersState {
  /// Creates order-history state.
  const AccountOrdersState({
    this.status = AccountOrdersStatus.idle,
    this.orders = const [],
    this.hasLoaded = false,
    this.failure = const None(),
  });

  /// Failure classification for localized presentation.
  final Option<AccountOrdersFailure> failure;

  /// Whether at least one complete server response has been accepted.
  final bool hasLoaded;

  /// Server-owned previous orders.
  final List<Order> orders;

  /// Current loading state.
  final AccountOrdersStatus status;
}
