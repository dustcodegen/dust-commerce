import 'package:admin_app/src/customer/admin_customer_address_create_state.dart';
import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_address_create_view_model.g.dart';

/// Dependencies for authenticated customer-address creation.
final class AdminCustomerAddressCreateViewModelArgs extends ViewModelArgs {
  /// Creates address command dependencies.
  const AdminCustomerAddressCreateViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated Admin customer client with Dio-owned authorization.
  final AdminCustomerApi api;
}

/// Commits one focused address form and retains its typed customer response.
@ViewModel(
  state: AdminCustomerAddressCreateState,
  args: AdminCustomerAddressCreateViewModelArgs,
)
final class AdminCustomerAddressCreateViewModel
    extends $AdminCustomerAddressCreateViewModel {
  /// Creates the address command state machine.
  AdminCustomerAddressCreateViewModel(super.args);

  /// Persists [input] beneath [customerId] and returns refreshed detail.
  Future<Option<AdminCustomerDetail>> create(
    String customerId,
    AdminCreateCustomerAddress input,
  ) async {
    emit(const AdminCustomerAddressCreateState(
      status: AdminCustomerAddressCreateStatus.saving,
    ));
    try {
      final customer = await args.api.createCustomerAddress(customerId, input);
      emit(AdminCustomerAddressCreateState(
        status: AdminCustomerAddressCreateStatus.ready,
        created: Some(customer),
      ));
      return Some(customer);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        404 => 'This customer no longer exists.',
        422 => 'Check the address details and try again.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to create this address. Try again.',
      });
      return const None();
    } on Object {
      _fail('Unable to create this address. Try again.');
      return const None();
    }
  }

  /// Clears one display error before a retry.
  void clearFailure() => emit(const AdminCustomerAddressCreateState(
        status: AdminCustomerAddressCreateStatus.ready,
      ));

  void _fail(String message) => emit(AdminCustomerAddressCreateState(
        status: AdminCustomerAddressCreateStatus.ready,
        failure: Some(message),
      ));
}
