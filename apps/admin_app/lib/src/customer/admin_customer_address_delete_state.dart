import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_address_delete_state.g.dart';

/// Lifecycle of the destructive customer-address command.
enum AdminCustomerAddressDeleteStatus {
  /// No deletion is active.
  idle,

  /// One address is being removed.
  deleting,

  /// The command completed or can be retried.
  ready,
}

/// Immutable command state for merchant address deletion.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminCustomerAddressDeleteState
    with _$AdminCustomerAddressDeleteState {
  /// Creates empty address-deletion state.
  const AdminCustomerAddressDeleteState({
    this.status = AdminCustomerAddressDeleteStatus.idle,
    this.deleted = const None(),
    this.failure = const None(),
  });

  /// Exact delete-with-parent acknowledgement.
  final Option<AdminCustomerAddressDeleted> deleted;

  /// Display-safe command failure.
  final Option<String> failure;

  /// Current deletion lifecycle.
  final AdminCustomerAddressDeleteStatus status;

  /// Whether another destructive submission must be blocked.
  bool get isBusy => status == AdminCustomerAddressDeleteStatus.deleting;
}
