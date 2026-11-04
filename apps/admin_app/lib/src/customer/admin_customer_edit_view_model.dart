import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_edit_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_edit_view_model.g.dart';

/// Dependencies for authenticated customer editing.
final class AdminCustomerEditViewModelArgs extends ViewModelArgs {
  /// Creates customer-edit dependencies.
  const AdminCustomerEditViewModelArgs({required this.api, super.observer});

  /// Generated Admin customer client with Dio-owned authorization.
  final AdminCustomerApi api;
}

/// Commits one focused customer edit and retains its typed response.
@ViewModel(
  state: AdminCustomerEditState,
  args: AdminCustomerEditViewModelArgs,
)
final class AdminCustomerEditViewModel extends $AdminCustomerEditViewModel {
  /// Creates the customer-edit state machine.
  AdminCustomerEditViewModel(super.args);

  /// Persists [input] and returns the updated customer when successful.
  Future<Option<AdminCustomerDetail>> update(
    String id,
    AdminUpdateCustomer input,
  ) async {
    emit(const AdminCustomerEditState(status: AdminCustomerEditStatus.saving));
    try {
      final customer = await args.api.updateCustomer(id, input);
      emit(AdminCustomerEditState(
        status: AdminCustomerEditStatus.ready,
        updated: Some(customer),
      ));
      return Some(customer);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        404 => 'This customer no longer exists.',
        401 => 'Your admin session has expired.',
        409 => 'This email cannot be used for this customer.',
        422 => 'Check the customer details and try again.',
        _ => 'Unable to update this customer. Try again.',
      });
      return const None();
    } on Object {
      _fail('Unable to update this customer. Try again.');
      return const None();
    }
  }

  /// Clears one display error before a retry.
  void clearFailure() => emit(const AdminCustomerEditState(
        status: AdminCustomerEditStatus.ready,
      ));

  void _fail(String message) => emit(AdminCustomerEditState(
        status: AdminCustomerEditStatus.ready,
        failure: Some(message),
      ));
}
