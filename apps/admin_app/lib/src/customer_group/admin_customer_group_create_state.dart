import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_group_create_state.g.dart';

/// Lifecycle of the focused customer-group create command.
enum AdminCustomerGroupCreateStatus {
  /// No submission is active.
  idle,

  /// One customer group is being persisted.
  saving,

  /// The form can accept or retry input.
  ready,
}

/// Immutable command state for merchant customer-group creation.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerGroupCreateState with _$AdminCustomerGroupCreateState {
  /// Creates empty customer-group command state.
  const AdminCustomerGroupCreateState({
    this.status = AdminCustomerGroupCreateStatus.idle,
    this.created = const None(),
    this.failure = const None(),
  });

  /// Group returned after successful creation.
  final Option<AdminCustomerGroup> created;

  /// Display-safe submission failure.
  final Option<String> failure;

  /// Current submission lifecycle.
  final AdminCustomerGroupCreateStatus status;

  /// Whether the form must reject duplicate submission.
  bool get isBusy => status == AdminCustomerGroupCreateStatus.saving;
}
