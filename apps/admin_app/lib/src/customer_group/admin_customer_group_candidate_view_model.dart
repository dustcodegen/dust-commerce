import 'package:admin_app/src/customer_group/admin_customer_group_api.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_candidate_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_customer_group_candidate_view_model.g.dart';

/// Dependencies for the authenticated Add Customers candidate list.
final class AdminCustomerGroupCandidateViewModelArgs extends ViewModelArgs {
  /// Creates candidate-list dependencies.
  const AdminCustomerGroupCandidateViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated Admin client with Dio-owned authorization.
  final AdminCustomerGroupApi api;
}

/// Loads independent candidate pages without disturbing the Customers route.
@ViewModel(
  state: AdminCustomerGroupCandidateState,
  args: AdminCustomerGroupCandidateViewModelArgs,
)
final class AdminCustomerGroupCandidateViewModel
    extends $AdminCustomerGroupCandidateViewModel {
  /// Creates the customer-group candidate state machine.
  AdminCustomerGroupCandidateViewModel(super.args);

  int _revision = 0;

  /// Loads one customer candidate page with current or supplied controls.
  Future<void> load({
    String? query,
    int? offset,
    Option<bool>? hasAccount,
    AdminCustomerOrder? order,
  }) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final nextAccount = hasAccount ?? state.hasAccount;
    final nextOrder = order ?? state.order;
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminCustomerGroupCandidateStatus.loading,
      query: nextQuery,
      offset: nextOffset,
      hasAccount: nextAccount,
      order: nextOrder,
      failure: const None(),
    ));
    try {
      final result = await args.api.listCustomerGroupCandidates(
        nextQuery,
        switch (nextAccount) {
          Some(:final value) => value.toString(),
          None() => '',
        },
        nextOrder.parameter,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(state.copyWith(
        status: AdminCustomerGroupCandidateStatus.ready,
        customers: List.unmodifiable(result.customers),
        count: result.count,
        limit: result.limit,
        offset: result.offset,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load customers. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load customers. Try again.');
    }
  }

  /// Searches from the first candidate page.
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Loads the preceding candidate page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following candidate page.
  Future<void> next() => load(offset: state.offset + state.limit);

  void _fail(String message) => emit(state.copyWith(
        status: AdminCustomerGroupCandidateStatus.failed,
        failure: Some(message),
      ));
}
