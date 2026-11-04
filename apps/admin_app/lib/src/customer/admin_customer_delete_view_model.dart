import 'package:admin_app/src/customer/admin_customer_api.dart';
import 'package:admin_app/src/customer/admin_customer_delete_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_delete_view_model.g.dart';

/// Dependencies for authenticated customer deletion.
final class AdminCustomerDeleteViewModelArgs extends ViewModelArgs {
  /// Creates customer-deletion dependencies.
  const AdminCustomerDeleteViewModelArgs({required this.api, super.observer});

  /// Generated Admin client with Dio-owned authorization.
  final AdminCustomerApi api;
}

/// Deletes one customer boundary and retains its typed acknowledgement.
@ViewModel(
  state: AdminCustomerDeleteState,
  args: AdminCustomerDeleteViewModelArgs,
)
final class AdminCustomerDeleteViewModel extends $AdminCustomerDeleteViewModel {
  /// Creates the customer-deletion state machine.
  AdminCustomerDeleteViewModel(super.args);

  /// Deletes [id] once and returns the exact acknowledgement on success.
  Future<Option<AdminCustomerDeleted>> delete(String id) async {
    if (state.isBusy) return const None();
    emit(const AdminCustomerDeleteState(
      status: AdminCustomerDeleteStatus.deleting,
    ));
    try {
      final deleted = await args.api.deleteCustomer(id);
      emit(AdminCustomerDeleteState(
        status: AdminCustomerDeleteStatus.ready,
        deleted: Some(deleted),
      ));
      return Some(deleted);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        404 => 'This customer no longer exists.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to delete this customer. Try again.',
      });
      return const None();
    } on Object {
      _fail('Unable to delete this customer. Try again.');
      return const None();
    }
  }

  /// Clears one display error before a retry.
  void clearFailure() => emit(const AdminCustomerDeleteState(
        status: AdminCustomerDeleteStatus.ready,
      ));

  void _fail(String message) => emit(AdminCustomerDeleteState(
        status: AdminCustomerDeleteStatus.ready,
        failure: Some(message),
      ));
}
