import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_group_membership_state.g.dart';

/// Lifecycle of one focused customer-group membership command.
enum AdminCustomerGroupMembershipStatus {
  /// No membership update is active.
  idle,

  /// One add/remove batch is being submitted.
  updating,

  /// The command completed or can be retried.
  ready,
}

/// Immutable state for adding or removing customer-group members.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerGroupMembershipState
    with _$AdminCustomerGroupMembershipState {
  /// Creates empty customer-group membership state.
  const AdminCustomerGroupMembershipState({
    this.status = AdminCustomerGroupMembershipStatus.idle,
    this.customerGroup = const None(),
    this.failure = const None(),
  });

  /// Refreshed direct group detail after a successful batch.
  final Option<AdminCustomerGroupDetail> customerGroup;

  /// Display-safe command failure.
  final Option<String> failure;

  /// Current membership command lifecycle.
  final AdminCustomerGroupMembershipStatus status;

  /// Whether another membership submission must be blocked.
  bool get isBusy => status == AdminCustomerGroupMembershipStatus.updating;
}
