import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_edit_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_group_edit_view_model.g.dart';

/// Dependencies for authenticated customer-group editing.
final class AdminCustomerGroupEditViewModelArgs extends ViewModelArgs {
  /// Creates customer-group edit dependencies.
  const AdminCustomerGroupEditViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated Admin client with Dio-owned authorization.
  final AdminCustomerGroupApi api;
}

/// Commits one focused group edit and retains the refreshed response.
@ViewModel(
  state: AdminCustomerGroupEditState,
  args: AdminCustomerGroupEditViewModelArgs,
)
final class AdminCustomerGroupEditViewModel
    extends $AdminCustomerGroupEditViewModel {
  /// Creates the customer-group edit state machine.
  AdminCustomerGroupEditViewModel(super.args);

  /// Persists [input] and returns the updated group when successful.
  Future<Option<AdminCustomerGroupDetail>> update(
    String id,
    AdminUpdateCustomerGroup input,
  ) async {
    emit(const AdminCustomerGroupEditState(
      status: AdminCustomerGroupEditStatus.saving,
    ));
    try {
      final response = await args.api.updateCustomerGroup(id, input);
      final group = response.customerGroup;
      emit(AdminCustomerGroupEditState(
        status: AdminCustomerGroupEditStatus.ready,
        updated: Some(group),
      ));
      return Some(group);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        404 => 'This customer group no longer exists.',
        401 => 'Your admin session has expired.',
        422 => 'Check the customer group details and try again.',
        _ => 'Unable to update this customer group. Try again.',
      });
      return const None();
    } on Object {
      _fail('Unable to update this customer group. Try again.');
      return const None();
    }
  }

  /// Clears one display error before a retry.
  void clearFailure() => emit(const AdminCustomerGroupEditState(
        status: AdminCustomerGroupEditStatus.ready,
      ));

  void _fail(String message) => emit(AdminCustomerGroupEditState(
        status: AdminCustomerGroupEditStatus.ready,
        failure: Some(message),
      ));
}
