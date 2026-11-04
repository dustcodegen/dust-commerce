import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_create_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_group_create_view_model.g.dart';

/// Dependencies for authenticated customer-group creation.
final class AdminCustomerGroupCreateViewModelArgs extends ViewModelArgs {
  /// Creates customer-group command dependencies.
  const AdminCustomerGroupCreateViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated Admin client with Dio-owned authorization.
  final AdminCustomerGroupApi api;
}

/// Commits one focused customer-group form and retains its typed response.
@ViewModel(
  state: AdminCustomerGroupCreateState,
  args: AdminCustomerGroupCreateViewModelArgs,
)
final class AdminCustomerGroupCreateViewModel
    extends $AdminCustomerGroupCreateViewModel {
  /// Creates the customer-group command state machine.
  AdminCustomerGroupCreateViewModel(super.args);

  /// Persists [input] and returns its allowlisted customer group.
  Future<Option<AdminCustomerGroup>> create(
    AdminCreateCustomerGroup input,
  ) async {
    emit(const AdminCustomerGroupCreateState(
      status: AdminCustomerGroupCreateStatus.saving,
    ));
    try {
      final response = await args.api.createCustomerGroup(input);
      final group = response.customerGroup;
      emit(AdminCustomerGroupCreateState(
        status: AdminCustomerGroupCreateStatus.ready,
        created: Some(group),
      ));
      return Some(group);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        422 => 'Check the customer group details and try again.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to create this customer group. Try again.',
      });
      return const None();
    } on Object {
      _fail('Unable to create this customer group. Try again.');
      return const None();
    }
  }

  /// Clears one display error before a retry.
  void clearFailure() => emit(const AdminCustomerGroupCreateState(
        status: AdminCustomerGroupCreateStatus.ready,
      ));

  void _fail(String message) => emit(AdminCustomerGroupCreateState(
        status: AdminCustomerGroupCreateStatus.ready,
        failure: Some(message),
      ));
}
