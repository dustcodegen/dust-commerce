import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/derive.dart';

part 'order_return_history_state.g.dart';

/// Lifecycle of an authenticated customer's return-history request.
enum OrderReturnHistoryStatus {
  /// No order owns the history yet.
  idle,

  /// The first bounded page is loading.
  loading,

  /// Loaded rows and metadata are current.
  ready,

  /// A later page is loading while current rows remain visible.
  loadingMore,

  /// The latest request failed with display-safe classification.
  failed,
}

/// Display decision for a failed history read.
enum OrderReturnHistoryFailure {
  /// The customer bearer is no longer accepted.
  sessionExpired,

  /// The order is missing or owned by another customer.
  unavailable,

  /// A transport or unexpected server failure may succeed on retry.
  retryable,
}

/// Immutable paginated return history with explicit absence values.
@Derive([ToString(), Eq(), CopyWith()])
final class OrderReturnHistoryState with _$OrderReturnHistoryState {
  /// Creates empty or loaded return history.
  const OrderReturnHistoryState({
    this.status = OrderReturnHistoryStatus.idle,
    this.orderId = const None(),
    this.returns = const [],
    this.count = 0,
    this.offset = 0,
    this.failure = const None(),
  });

  /// Total server-owned active returns for this order.
  final int count;

  /// Display-safe failure from the latest page request.
  final Option<OrderReturnHistoryFailure> failure;

  /// Authenticated order currently owning these rows.
  final Option<String> orderId;

  /// Number of server rows consumed across page requests.
  final int offset;

  /// Customer-visible return allowlists, newest first.
  final List<OrderReturnView> returns;

  /// Current page lifecycle.
  final OrderReturnHistoryStatus status;

  /// Whether another bounded server page exists.
  bool get hasMore => offset < count;
}
