import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_edit_state.g.dart';

/// Lifecycle of the focused customer-edit command.
enum AdminCustomerEditStatus {
  /// No update is active.
  idle,

  /// One replacement is being persisted.
  saving,

  /// The form can accept or retry input.
  ready,
}

/// Immutable command state for merchant customer editing.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerEditState with _$AdminCustomerEditState {
  /// Creates empty customer-edit state.
  const AdminCustomerEditState({
    this.status = AdminCustomerEditStatus.idle,
    this.updated = const None(),
    this.failure = const None(),
  });

  /// Display-safe submission failure.
  final Option<String> failure;

  /// Current submission lifecycle.
  final AdminCustomerEditStatus status;

  /// Allowlisted customer detail returned after a successful update.
  final Option<AdminCustomerDetail> updated;

  /// Whether the form must reject duplicate submission.
  bool get isBusy => status == AdminCustomerEditStatus.saving;
}
