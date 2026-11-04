import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_create_state.g.dart';

/// Lifecycle of the focused customer-create form.
enum AdminCustomerCreateStatus {
  /// No submission is active.
  idle,

  /// One customer is being persisted.
  saving,

  /// The form can accept or retry input.
  ready,
}

/// Immutable command state for merchant customer creation.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerCreateState with _$AdminCustomerCreateState {
  /// Creates empty form command state.
  const AdminCustomerCreateState({
    this.status = AdminCustomerCreateStatus.idle,
    this.created = const None(),
    this.failure = const None(),
  });

  /// Allowlisted customer detail returned after successful creation.
  final Option<AdminCustomerDetail> created;

  /// Display-safe submission failure.
  final Option<String> failure;

  /// Current submission lifecycle.
  final AdminCustomerCreateStatus status;

  /// Whether the form must reject duplicate submission.
  bool get isBusy => status == AdminCustomerCreateStatus.saving;
}
