import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_return_state.g.dart';

/// Lifecycle of requested returns attached to one Admin order.
enum AdminReturnLoadStatus {
  /// No request has started.
  idle,

  /// The generated client request is active.
  loading,

  /// The requested return list is ready.
  ready,

  /// A merchant receipt command is active.
  saving,

  /// The request failed with a display-safe message.
  failed,
}

/// Immutable state for Medusa's order-detail receive-return action.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminReturnState with _$AdminReturnState {
  /// Creates return state without transport objects.
  const AdminReturnState({
    this.status = AdminReturnLoadStatus.idle,
    this.returns = const [],
    this.failure = const None(),
  });

  /// Display-safe failure when loading requested returns fails.
  final Option<String> failure;

  /// Requested returns that are still eligible for receipt.
  final List<AdminReturn> returns;

  /// Current request lifecycle.
  final AdminReturnLoadStatus status;
}
