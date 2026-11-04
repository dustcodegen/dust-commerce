import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_group_edit_state.g.dart';

/// Lifecycle of one focused customer-group edit command.
enum AdminCustomerGroupEditStatus {
  /// No update is active.
  idle,

  /// One name replacement is being persisted.
  saving,

  /// The form can accept or retry input.
  ready,
}

/// Immutable command state for merchant customer-group editing.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerGroupEditState with _$AdminCustomerGroupEditState {
  /// Creates empty customer-group edit state.
  const AdminCustomerGroupEditState({
    this.status = AdminCustomerGroupEditStatus.idle,
    this.updated = const None(),
    this.failure = const None(),
  });

  /// Display-safe submission failure.
  final Option<String> failure;

  /// Current submission lifecycle.
  final AdminCustomerGroupEditStatus status;

  /// Refreshed allowlisted group detail after a successful update.
  final Option<AdminCustomerGroupDetail> updated;

  /// Whether the form must reject duplicate submission.
  bool get isBusy => status == AdminCustomerGroupEditStatus.saving;
}
