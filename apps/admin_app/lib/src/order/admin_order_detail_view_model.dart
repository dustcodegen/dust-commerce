import 'package:admin_app/src/order/admin_order_detail_api.dart';
import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_payment_refund_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_order_detail_view_model.g.dart';
part 'admin_order_cancellation_view_model.dart';
part 'admin_order_delivery_view_model.dart';
part 'admin_payment_refund_view_model.dart';

/// Dependencies for one authenticated merchant order detail.
final class AdminOrderDetailViewModelArgs extends ViewModelArgs {
  /// Creates order-detail dependencies.
  const AdminOrderDetailViewModelArgs({required this.api, super.observer});

  /// Generated order-detail API using Dio-level authorization.
  final AdminOrderDetailApi api;
}

/// Loads one frozen order without exposing transport objects to widgets.
@ViewModel(
  state: AdminOrderDetailState,
  args: AdminOrderDetailViewModelArgs,
)
final class AdminOrderDetailViewModel extends $AdminOrderDetailViewModel {
  /// Creates the order-detail state machine.
  AdminOrderDetailViewModel(super.args);

  int _revision = 0;

  /// Loads the complete allowlisted detail for [id].
  Future<void> load(String id) async {
    final revision = ++_revision;
    emit(const AdminOrderDetailState(status: AdminOrderDetailStatus.loading));
    try {
      final order = await args.api.order(id);
      if (revision != _revision) return;
      emit(AdminOrderDetailState(
        status: AdminOrderDetailStatus.ready,
        order: Some(order),
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(switch (error.response?.statusCode) {
        404 => 'This order no longer exists.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to load this order. Try again.',
      });
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load this order. Try again.');
    }
  }

  /// Creates one fulfillment and replaces state with the refreshed order.
  Future<bool> createFulfillment(
    String orderId,
    AdminCreateFulfillment body,
  ) async {
    final revision = _beginSave();
    try {
      final order = await args.api.createFulfillment(orderId, body);
      return _publishSaved(revision, order);
    } on DioException catch (error) {
      if (revision != _revision) return false;
      _saveFailure(switch (error.response?.statusCode) {
        401 => 'Your admin session has expired.',
        404 => 'This order no longer exists.',
        422 => 'Fulfillment command is invalid.',
        503 => 'Fulfillment notification is not configured.',
        _ => 'Unable to create this fulfillment. Try again.',
      });
      return false;
    } on Object {
      if (revision != _revision) return false;
      _saveFailure('Unable to create this fulfillment. Try again.');
      return false;
    }
  }

  /// Marks one fulfillment shipped and replaces state with the refreshed order.
  Future<bool> createShipment(
    String orderId,
    String fulfillmentId,
    AdminCreateShipment body,
  ) async {
    final revision = _beginSave();
    try {
      final order = await args.api.createShipment(
        orderId,
        fulfillmentId,
        body,
      );
      return _publishSaved(revision, order);
    } on DioException catch (error) {
      if (revision != _revision) return false;
      _saveFailure(switch (error.response?.statusCode) {
        401 => 'Your admin session has expired.',
        404 => 'This fulfillment no longer exists.',
        422 => 'Shipment command is invalid.',
        503 => 'Shipment notification is not configured.',
        _ => 'Unable to create this shipment. Try again.',
      });
      return false;
    } on Object {
      if (revision != _revision) return false;
      _saveFailure('Unable to create this shipment. Try again.');
      return false;
    }
  }

  int _beginSave() {
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminOrderDetailStatus.saving,
      failure: const None(),
    ));
    return revision;
  }

  int _beginRefundSave() {
    final revision = _beginSave();
    emit(state.copyWith(
        refund: state.refund.copyWith(
      status: AdminPaymentRefundStatus.saving,
      failure: const None(),
    )));
    return revision;
  }

  void _publishRefund(AdminPaymentRefundState refund) =>
      emit(state.copyWith(refund: refund));

  void _failRefund(String message) => emit(state.copyWith(
        status: AdminOrderDetailStatus.failed,
        failure: Some(message),
        refund: state.refund.copyWith(
          status: AdminPaymentRefundStatus.failed,
          failure: Some(message),
        ),
      ));

  bool _publishSaved(int revision, AdminOrderDetail order) {
    if (revision != _revision) return false;
    emit(AdminOrderDetailState(
      status: AdminOrderDetailStatus.ready,
      order: Some(order),
    ));
    return true;
  }

  void _fail(String message) => emit(AdminOrderDetailState(
        status: AdminOrderDetailStatus.failed,
        failure: Some(message),
      ));

  void _saveFailure(String message) => emit(state.copyWith(
        status: AdminOrderDetailStatus.failed,
        failure: Some(message),
      ));
}
