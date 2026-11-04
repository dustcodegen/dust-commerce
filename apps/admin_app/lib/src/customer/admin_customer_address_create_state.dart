import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_address_create_state.g.dart';

/// Lifecycle of the focused customer-address create command.
enum AdminCustomerAddressCreateStatus {
  /// No submission is active.
  idle,

  /// One address is being persisted.
  saving,

  /// The form can accept or retry input.
  ready,
}

/// Immutable command state for merchant customer-address creation.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerAddressCreateState
    with _$AdminCustomerAddressCreateState {
  /// Creates empty address command state.
  const AdminCustomerAddressCreateState({
    this.status = AdminCustomerAddressCreateStatus.idle,
    this.created = const None(),
    this.failure = const None(),
  });

  /// Refreshed customer returned after successful creation.
  final Option<AdminCustomerDetail> created;

  /// Display-safe submission failure.
  final Option<String> failure;

  /// Current submission lifecycle.
  final AdminCustomerAddressCreateStatus status;

  /// Whether the form must reject duplicate submission.
  bool get isBusy => status == AdminCustomerAddressCreateStatus.saving;
}
