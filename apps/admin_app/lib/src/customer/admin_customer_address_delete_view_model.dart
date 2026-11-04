import 'package:admin_app/src/customer/admin_customer_address_delete_state.dart';
import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_address_delete_view_model.g.dart';

/// Dependencies for authenticated customer-address deletion.
final class AdminCustomerAddressDeleteViewModelArgs extends ViewModelArgs {
  /// Creates address-deletion dependencies.
  const AdminCustomerAddressDeleteViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated Admin customer client with Dio-owned authorization.
  final AdminCustomerApi api;
}

/// Deletes one owned address and retains the typed parent acknowledgement.
@ViewModel(
  state: AdminCustomerAddressDeleteState,
  args: AdminCustomerAddressDeleteViewModelArgs,
)
final class AdminCustomerAddressDeleteViewModel
    extends $AdminCustomerAddressDeleteViewModel {
  /// Creates the address-deletion state machine.
  AdminCustomerAddressDeleteViewModel(super.args);

  /// Deletes [addressId] beneath [customerId] exactly once.
  Future<Option<AdminCustomerAddressDeleted>> delete(
    String customerId,
    String addressId,
  ) async {
    if (state.isBusy) return const None();
    emit(const AdminCustomerAddressDeleteState(
      status: AdminCustomerAddressDeleteStatus.deleting,
    ));
    try {
      final deleted =
          await args.api.deleteCustomerAddress(customerId, addressId);
      emit(AdminCustomerAddressDeleteState(
        status: AdminCustomerAddressDeleteStatus.ready,
        deleted: Some(deleted),
      ));
      return Some(deleted);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        404 => 'This address no longer exists.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to delete this address. Try again.',
      });
      return const None();
    } on Object {
      _fail('Unable to delete this address. Try again.');
      return const None();
    }
  }

  /// Clears one display error before a retry.
  void clearFailure() => emit(const AdminCustomerAddressDeleteState(
        status: AdminCustomerAddressDeleteStatus.ready,
      ));

  void _fail(String message) => emit(AdminCustomerAddressDeleteState(
        status: AdminCustomerAddressDeleteStatus.ready,
        failure: Some(message),
      ));
}
