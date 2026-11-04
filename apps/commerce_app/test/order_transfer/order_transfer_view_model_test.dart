import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('request normalizes the id and retains only public delivery state',
      () async {
    var requestedId = '';
    final model = OrderTransferViewModel(OrderTransferViewModelArgs(
      api: _RequestApi((id) async {
        requestedId = id;
        return _view(id, delivery: OrderTransferDeliveryStatus.sent);
      }),
    ));

    await model.request('  order_1  ');

    expect(requestedId, 'order_1');
    expect(model.state.status, OrderTransferActionStatus.succeeded);
    expect(model.state.action, const Some(OrderTransferAction.request));
    expect(model.state.orderId, const Some('order_1'));
    expect(
      model.state.deliveryStatus,
      const Some(OrderTransferDeliveryStatus.sent),
    );
    model.dispose();
  });

  test('request exposes queued delivery as accepted but still pending email',
      () async {
    final model = OrderTransferViewModel(OrderTransferViewModelArgs(
      api: _RequestApi((id) async => _view(
            id,
            delivery: OrderTransferDeliveryStatus.queued,
          )),
    ));

    await model.request('order_queued');

    expect(model.state.status, OrderTransferActionStatus.succeeded);
    expect(
      model.state.deliveryStatus,
      const Some(OrderTransferDeliveryStatus.queued),
    );
    model.dispose();
  });

  test('invalid request maps one protocol failure for the form', () async {
    final request = RequestOptions(path: '/store/orders/missing/transfer');
    final error = DioException(
      requestOptions: request,
      response: Response<void>(requestOptions: request, statusCode: 422),
    );
    final model = OrderTransferViewModel(OrderTransferViewModelArgs(
      api: _RequestApi((_) => Future<OrderTransferView>.error(error)),
    ));

    await model.request('missing');

    expect(model.state.status, OrderTransferActionStatus.failed);
    expect(
      model.state.failure,
      const Some(OrderTransferFailure.invalidRequest),
    );
    model.dispose();
  });

  test('decision capability never enters generated state', () async {
    const capability = 'secret-capability';
    var submittedToken = '';
    final model = OrderTransferViewModel(OrderTransferViewModelArgs(
      api: _AcceptApi((id, body) async {
        submittedToken = body.token;
        return _view(id, status: OrderTransferStatus.accepted);
      }),
    ));

    await model.accept('order_1', capability);

    expect(submittedToken, capability);
    expect(model.state.action, const Some(OrderTransferAction.accept));
    expect(model.state.toString(), isNot(contains(capability)));
    model.dispose();
  });

  test('invalid or expired capability gets one unavailable state', () async {
    final request = RequestOptions(path: '/store/orders/order_1/transfer');
    final error = DioException(
      requestOptions: request,
      response: Response<void>(requestOptions: request, statusCode: 404),
    );
    final model = OrderTransferViewModel(OrderTransferViewModelArgs(
      api: _AcceptApi((_, __) => Future<OrderTransferView>.error(error)),
    ));

    await model.accept('order_1', 'unknown');

    expect(model.state.status, OrderTransferActionStatus.failed);
    expect(
      model.state.failure,
      const Some(OrderTransferFailure.unavailable),
    );
    model.dispose();
  });

  test('an order changed after requesting has a decision-safe failure',
      () async {
    final request = RequestOptions(path: '/store/orders/order_1/transfer');
    final error = DioException(
      requestOptions: request,
      response: Response<void>(requestOptions: request, statusCode: 422),
    );
    final model = OrderTransferViewModel(OrderTransferViewModelArgs(
      api: _AcceptApi((_, __) => Future<OrderTransferView>.error(error)),
    ));

    await model.accept('order_1', 'capability');

    expect(
      model.state.failure,
      const Some(OrderTransferFailure.orderUnavailable),
    );
    model.dispose();
  });

  test('reset rejects an in-flight result from an earlier screen', () async {
    final deferred = Completer<OrderTransferView>();
    final model = OrderTransferViewModel(OrderTransferViewModelArgs(
      api: _RequestApi((_) => deferred.future),
    ));

    final pending = model.request('order_1');
    model.reset();
    deferred.complete(_view('order_1'));
    await pending;

    expect(model.state, const OrderTransferState());
    model.dispose();
  });
}

final class _RequestApi implements CommerceApi {
  const _RequestApi(this.call);

  final Future<OrderTransferView> Function(String id) call;

  @override
  Future<OrderTransferView> requestOrderTransfer(String id) => call(id);

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unused API method');
}

final class _AcceptApi implements CommerceApi {
  const _AcceptApi(this.call);

  final Future<OrderTransferView> Function(
    String id,
    OrderTransferDecisionBody body,
  ) call;

  @override
  Future<OrderTransferView> acceptOrderTransfer(
    String id,
    OrderTransferDecisionBody body,
  ) =>
      call(id, body);

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unused API method');
}

OrderTransferView _view(
  String orderId, {
  OrderTransferStatus status = OrderTransferStatus.requested,
  OrderTransferDeliveryStatus delivery = OrderTransferDeliveryStatus.sent,
}) =>
    OrderTransferView(
      id: 'transfer_1',
      orderId: orderId,
      status: status,
      deliveryStatus: delivery,
      expiresAt: DateTime.utc(2026, 9, 7),
    );
