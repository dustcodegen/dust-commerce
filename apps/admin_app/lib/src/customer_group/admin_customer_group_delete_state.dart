import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_group_delete_state.g.dart';

/// Lifecycle of one focused customer-group deletion command.
enum AdminCustomerGroupDeleteStatus {
  /// No deletion is active.
  idle,

  /// One customer-group graph is being retired.
  deleting,

  /// The command completed or can be retried.
  ready,
}

/// Immutable command state for merchant customer-group deletion.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerGroupDeleteState with _$AdminCustomerGroupDeleteState {
  /// Creates empty customer-group deletion state.
  const AdminCustomerGroupDeleteState({
    this.status = AdminCustomerGroupDeleteStatus.idle,
    this.deleted = const None(),
    this.failure = const None(),
  });

  /// Exact allowlisted deletion acknowledgement.
  final Option<AdminCustomerGroupDeleted> deleted;

  /// Display-safe command failure.
  final Option<String> failure;

  /// Current deletion lifecycle.
  final AdminCustomerGroupDeleteStatus status;

  /// Whether another destructive submission must be blocked.
  bool get isBusy => status == AdminCustomerGroupDeleteStatus.deleting;
}
