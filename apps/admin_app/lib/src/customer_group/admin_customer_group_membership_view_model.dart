import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_membership_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_group_membership_view_model.g.dart';

/// Dependencies for authenticated customer-group membership updates.
final class AdminCustomerGroupMembershipViewModelArgs extends ViewModelArgs {
  /// Creates customer-group membership dependencies.
  const AdminCustomerGroupMembershipViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated Admin client with Dio-owned authorization.
  final AdminCustomerGroupApi api;
}

/// Applies one add/remove batch and retains the refreshed direct detail.
@ViewModel(
  state: AdminCustomerGroupMembershipState,
  args: AdminCustomerGroupMembershipViewModelArgs,
)
final class AdminCustomerGroupMembershipViewModel
    extends $AdminCustomerGroupMembershipViewModel {
  /// Creates the customer-group membership state machine.
  AdminCustomerGroupMembershipViewModel(super.args);

  /// Updates [customerGroupId] once and returns its refreshed detail.
  Future<Option<AdminCustomerGroupDetail>> update(
    String customerGroupId, {
    List<String> add = const [],
    List<String> remove = const [],
  }) async {
    if (state.isBusy) return const None();
    emit(const AdminCustomerGroupMembershipState(
      status: AdminCustomerGroupMembershipStatus.updating,
    ));
    try {
      final response = await args.api.updateCustomerGroupCustomers(
        customerGroupId,
        AdminBatchCustomerGroupCustomers(add: add, remove: remove),
      );
      final group = response.customerGroup;
      emit(AdminCustomerGroupMembershipState(
        status: AdminCustomerGroupMembershipStatus.ready,
        customerGroup: Some(group),
      ));
      return Some(group);
    } on DioException catch (error) {
      _fail(switch (error.response?.statusCode) {
        422 => 'One or more customers cannot be updated.',
        404 => 'This customer group no longer exists.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to update group customers. Try again.',
      });
      return const None();
    } on Object {
      _fail('Unable to update group customers. Try again.');
      return const None();
    }
  }

  /// Clears transient result and failure state before another command.
  void reset() => emit(const AdminCustomerGroupMembershipState());

  void _fail(String message) => emit(AdminCustomerGroupMembershipState(
        status: AdminCustomerGroupMembershipStatus.ready,
        failure: Some(message),
      ));
}
