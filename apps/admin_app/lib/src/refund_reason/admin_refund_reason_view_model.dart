import 'package:admin_app/src/order/admin_order_detail_api.dart';
import 'package:admin_app/src/refund_reason/admin_refund_reason_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_refund_reason_view_model.g.dart';

/// Dependencies for the refund-reason settings route.
final class AdminRefundReasonViewModelArgs extends ViewModelArgs {
  /// Creates reason-settings dependencies.
  const AdminRefundReasonViewModelArgs({required this.api, super.observer});

  /// Generated Admin API using Dio-owned authorization.
  final AdminOrderDetailApi api;
}

/// Loads and mutates merchant refund reasons.
@ViewModel(
  state: AdminRefundReasonState,
  args: AdminRefundReasonViewModelArgs,
)
final class AdminRefundReasonViewModel extends $AdminRefundReasonViewModel {
  /// Creates the reason state machine.
  AdminRefundReasonViewModel(super.args);

  int _revision = 0;

  /// Loads one bounded page.
  Future<void> load({String? query, int? offset}) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminRefundReasonLoadStatus.loading,
      query: nextQuery,
      offset: nextOffset,
      failure: const None(),
    ));
    try {
      final page = await args.api.refundReasons(
        nextQuery,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(AdminRefundReasonState(
        status: AdminRefundReasonLoadStatus.ready,
        reasons: page.refundReasons,
        count: page.count,
        limit: page.limit,
        offset: page.offset,
        query: nextQuery,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load refund reasons. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load refund reasons. Try again.');
    }
  }

  /// Loads the preceding server page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following server page.
  Future<void> next() => load(offset: state.offset + state.limit);

  /// Creates or replaces one reason and refreshes the table.
  Future<bool> save({
    String? id,
    required String label,
    required String code,
    required String? description,
  }) async {
    final revision = ++_revision;
    emit(state.copyWith(failure: const None()));
    try {
      if (id == null) {
        await args.api.createRefundReason(AdminCreateRefundReason(
          label: label,
          code: code,
          descriptionValue: description,
        ));
      } else {
        await args.api.updateRefundReason(
          id,
          AdminUpdateRefundReason(
            label: label,
            code: code,
            descriptionValue: description,
          ),
        );
      }
      if (revision != _revision) return false;
      await load(query: state.query, offset: state.offset);
      return true;
    } on DioException catch (error) {
      if (revision != _revision) return false;
      _fail(_mutationFailure(error));
      return false;
    } on Object {
      if (revision != _revision) return false;
      _fail('Unable to save refund reason. Try again.');
      return false;
    }
  }

  /// Retires one reason and reloads the current page.
  Future<bool> retire(String id) async {
    emit(state.copyWith(busyId: Some(id), failure: const None()));
    try {
      await args.api.deleteRefundReason(id);
      await load(query: state.query, offset: state.offset);
      return true;
    } on DioException catch (error) {
      _fail(_mutationFailure(error));
      return false;
    } on Object {
      _fail('Unable to retire refund reason. Try again.');
      return false;
    }
  }

  void _fail(String message) => emit(state.copyWith(
        status: AdminRefundReasonLoadStatus.failed,
        failure: Some(message),
        busyId: const None(),
      ));

  String _mutationFailure(DioException error) =>
      switch (error.response?.statusCode) {
        401 => 'Your admin session has expired.',
        404 => 'This refund reason no longer exists.',
        409 => 'Another refund reason uses this code.',
        422 => 'Enter a valid label and code.',
        _ => 'Unable to save refund reason. Try again.',
      };
}
