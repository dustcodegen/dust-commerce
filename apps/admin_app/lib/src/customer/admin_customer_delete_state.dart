import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_delete_state.g.dart';

/// Lifecycle of the focused customer-deletion command.
enum AdminCustomerDeleteStatus {
  /// No deletion is active.
  idle,

  /// One customer graph is being removed.
  deleting,

  /// The command completed or can be retried.
  ready,
}

/// Immutable command state for merchant customer deletion.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerDeleteState with _$AdminCustomerDeleteState {
  /// Creates empty customer-deletion state.
  const AdminCustomerDeleteState({
    this.status = AdminCustomerDeleteStatus.idle,
    this.deleted = const None(),
    this.failure = const None(),
  });

  /// Exact allowlisted deletion acknowledgement.
  final Option<AdminCustomerDeleted> deleted;

  /// Display-safe command failure.
  final Option<String> failure;

  /// Current deletion lifecycle.
  final AdminCustomerDeleteStatus status;

  /// Whether another destructive submission must be blocked.
  bool get isBusy => status == AdminCustomerDeleteStatus.deleting;
}
