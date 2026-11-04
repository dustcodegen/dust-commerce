import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_create_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_create_view_model.g.dart';

/// Dependencies for authenticated customer creation.
final class AdminCustomerCreateViewModelArgs extends ViewModelArgs {
  /// Creates customer creation dependencies.
  const AdminCustomerCreateViewModelArgs({required this.api, super.observer});

  /// Generated Admin customer client with Dio-owned authorization.
  final AdminCustomerApi api;
}

/// Commits one focused customer form and retains its typed result.
@ViewModel(
  state: AdminCustomerCreateState,
  args: AdminCustomerCreateViewModelArgs,
)
final class AdminCustomerCreateViewModel extends $AdminCustomerCreateViewModel {
  /// Creates the customer creation state machine.
  AdminCustomerCreateViewModel(super.args);

  /// Persists [input] and returns the created customer when successful.
  Future<Option<AdminCustomerDetail>> create(AdminCreateCustomer input) async {
    emit(const AdminCustomerCreateState(
      status: AdminCustomerCreateStatus.saving,
    ));
    try {
      final customer = await args.api.createCustomer(input);
      emit(AdminCustomerCreateState(
        status: AdminCustomerCreateStatus.ready,
        created: Some(customer),
      ));
      return Some(customer);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        409 => 'A guest customer already uses this email.',
        422 => 'Check the customer details and try again.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to create this customer. Try again.',
      });
      return const None();
    } on Object {
      _fail('Unable to create this customer. Try again.');
      return const None();
    }
  }

  /// Clears one display error before a retry.
  void clearFailure() => emit(const AdminCustomerCreateState(
        status: AdminCustomerCreateStatus.ready,
      ));

  void _fail(String message) => emit(AdminCustomerCreateState(
        status: AdminCustomerCreateStatus.ready,
        failure: Some(message),
      ));
}
