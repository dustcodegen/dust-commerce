import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_delete_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_group_delete_view_model.g.dart';

/// Dependencies for authenticated customer-group deletion.
final class AdminCustomerGroupDeleteViewModelArgs extends ViewModelArgs {
  /// Creates customer-group deletion dependencies.
  const AdminCustomerGroupDeleteViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated Admin client with Dio-owned authorization.
  final AdminCustomerGroupApi api;
}

/// Deletes one customer group and retains its typed acknowledgement.
@ViewModel(
  state: AdminCustomerGroupDeleteState,
  args: AdminCustomerGroupDeleteViewModelArgs,
)
final class AdminCustomerGroupDeleteViewModel
    extends $AdminCustomerGroupDeleteViewModel {
  /// Creates the customer-group deletion state machine.
  AdminCustomerGroupDeleteViewModel(super.args);

  /// Deletes [id] once and returns the exact acknowledgement on success.
  Future<Option<AdminCustomerGroupDeleted>> delete(String id) async {
    if (state.isBusy) return const None();
    emit(const AdminCustomerGroupDeleteState(
      status: AdminCustomerGroupDeleteStatus.deleting,
    ));
    try {
      final deleted = await args.api.deleteCustomerGroup(id);
      emit(AdminCustomerGroupDeleteState(
        status: AdminCustomerGroupDeleteStatus.ready,
        deleted: Some(deleted),
      ));
      return Some(deleted);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        404 => 'This customer group no longer exists.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to delete this customer group. Try again.',
      });
      return const None();
    } on Object {
      _fail('Unable to delete this customer group. Try again.');
      return const None();
    }
  }

  /// Clears one display error before a retry.
  void clearFailure() => emit(const AdminCustomerGroupDeleteState(
        status: AdminCustomerGroupDeleteStatus.ready,
      ));

  void _fail(String message) => emit(AdminCustomerGroupDeleteState(
        status: AdminCustomerGroupDeleteStatus.ready,
        failure: Some(message),
      ));
}
