import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test('prepares only paid orders and owns item selection', () {
    final model = OrderReturnViewModel(
      OrderReturnViewModelArgs(api: _ReturnApi((_) async => _response)),
    );

    model.prepare(_paidOrder);
    model.toggle('item_1');
    model.setQuantity('item_1', 2);
    model.setNote('  Wrong size  ');

    expect(model.state.status, OrderReturnRequestStatus.ready);
    expect(model.state.orderId, const Some('order_1'));
    expect(model.state.quantities, const {'item_1': 2});
    expect(model.state.note, const Some('Wrong size'));
    model.dispose();
  });

  test('unpaid orders never expose a return selection', () {
    final model = OrderReturnViewModel(
      OrderReturnViewModelArgs(api: _ReturnApi((_) async => _response)),
    );

    model.prepare(_paidOrder.copyWith(
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.awaiting,
    ));

    expect(model.state.status, OrderReturnRequestStatus.failed);
    expect(model.state.orderId, const None<String>());
    expect(model.state.availableQuantities, isEmpty);
    expect(model.state.failure, const Some(OrderReturnFailure.notEligible));
    model.dispose();
  });

  test('prepares only the quantity remaining after active returns', () {
    final model = OrderReturnViewModel(
      OrderReturnViewModelArgs(api: _ReturnApi((_) async => _response)),
    );

    model.prepare(paidReturnOrder(requestedQuantity: 2));
    model.toggle('item_1');
    model.setQuantity('item_1', 2);

    expect(model.state.availableQuantities, const {'item_1': 1});
    expect(model.state.quantities, const {'item_1': 1});
    model.dispose();
  });

  test('fully exhausted order items cannot enter a new return', () {
    final model = OrderReturnViewModel(
      OrderReturnViewModelArgs(api: _ReturnApi((_) async => _response)),
    );

    model.prepare(paidReturnOrder(requestedQuantity: 3));
    model.toggle('item_1');

    expect(model.state.availableQuantities, isEmpty);
    expect(model.state.quantities, isEmpty);
    model.dispose();
  });

  test('return panel presentation remains in generated state', () {
    final model = OrderReturnViewModel(
      OrderReturnViewModelArgs(api: _ReturnApi((_) async => _response)),
    );
    model.prepare(_paidOrder);

    model.open();
    expect(model.state.expanded, isTrue);
    model.close();
    expect(model.state.expanded, isFalse);
    model.dispose();
  });

  test('submits one generated request and retains its acknowledgement',
      () async {
    OrderReturnRequestBody? submitted;
    final model = OrderReturnViewModel(OrderReturnViewModelArgs(
      api: _ReturnApi((body) async {
        submitted = body;
        return _response;
      }),
    ));
    model.prepare(_paidOrder);
    model.toggle('item_1');
    model.setQuantity('item_1', 2);
    model.setNote('Wrong size');

    await model.submit();

    expect(submitted?.orderId, 'order_1');
    expect(submitted?.items.single.itemId, 'item_1');
    expect(submitted?.items.single.quantity, 2);
    expect(submitted?.note, const Some('Wrong size'));
    expect(model.state.status, OrderReturnRequestStatus.succeeded);
    expect(model.state.request, Some(_response));
    model.dispose();
  });

  test('invalid selection and server rejection become safe failures', () async {
    var calls = 0;
    final request = RequestOptions(path: '/store/returns');
    final model = OrderReturnViewModel(OrderReturnViewModelArgs(
      api: _ReturnApi((_) {
        calls++;
        return Future.error(DioException(
          requestOptions: request,
          response: Response<void>(requestOptions: request, statusCode: 422),
        ));
      }),
    ));

    model.prepare(_paidOrder);
    await model.submit();
    expect(calls, 0);
    expect(
        model.state.failure, const Some(OrderReturnFailure.invalidSelection));

    model.toggle('item_1');
    await model.submit();
    expect(calls, 1);
    expect(model.state.failure, const Some(OrderReturnFailure.notEligible));
    model.dispose();
  });

  test('reset rejects an in-flight response from another order', () async {
    final deferred = Completer<OrderReturnView>();
    final model = OrderReturnViewModel(
      OrderReturnViewModelArgs(api: _ReturnApi((_) => deferred.future)),
    );
    model.prepare(_paidOrder);
    model.toggle('item_1');

    final pending = model.submit();
    model.reset();
    deferred.complete(_response);
    await pending;

    expect(model.state, const OrderReturnRequestState());
    model.dispose();
  });
}

final class _ReturnApi implements CommerceApi {
  const _ReturnApi(this.call);

  final Future<OrderReturnView> Function(OrderReturnRequestBody body) call;

  @override
  Future<OrderReturnView> requestOrderReturn(OrderReturnRequestBody body) =>
      call(body);

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unused API method');
}

final _response = OrderReturnView(
  id: 'return_1',
  displayId: 1,
  orderId: 'order_1',
  status: OrderReturnStatus.requested,
  itemQuantity: 2,
  requestedAt: returnInstant,
);

final Order _paidOrder = paidReturnOrder();
