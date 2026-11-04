import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test('loads every reason page and submits the selected item reason',
      () async {
    final offsets = <int>[];
    OrderReturnRequestBody? submitted;
    final model = OrderReturnViewModel(OrderReturnViewModelArgs(
      api: _ReasonApi(
        reasons: (limit, offset) async {
          offsets.add(offset ?? 0);
          return offset == 1
              ? _page([_wrongSize], 2, 1)
              : _page([_damaged], 2, 0);
        },
        request: (body) async {
          submitted = body;
          return _response;
        },
      ),
    ));
    model.prepare(_paidOrder);

    await model.loadReasons();
    model.toggle('item_1');
    model.setReason('item_1', const Some('reason_wrong_size'));
    await model.submit();

    expect(offsets, [0, 1]);
    expect(model.state.reasonStatus, OrderReturnReasonStatus.loaded);
    expect(model.state.reasons, [_damaged, _wrongSize]);
    expect(model.state.reasonIds, {'item_1': 'reason_wrong_size'});
    expect(submitted?.items.single.reasonId, const Some('reason_wrong_size'));
    model.dispose();
  });

  test('reason discovery distinguishes loading from an empty result', () async {
    final pending = Completer<ReturnReasonListView>();
    final model = OrderReturnViewModel(OrderReturnViewModelArgs(
      api: _ReasonApi(
        reasons: (_, __) => pending.future,
        request: (_) async => _response,
      ),
    ));
    model.prepare(_paidOrder);

    final load = model.loadReasons();
    expect(model.state.reasonStatus, OrderReturnReasonStatus.loading);
    pending.complete(_page(const [], 0, 0));
    await load;

    expect(model.state.reasonStatus, OrderReturnReasonStatus.loaded);
    expect(model.state.reasons, isEmpty);
    model.dispose();
  });

  test('reason discovery failure leaves the return form usable', () async {
    final model = OrderReturnViewModel(OrderReturnViewModelArgs(
      api: _ReasonApi(
        reasons: (_, __) => Future.error(StateError('offline')),
        request: (_) async => _response,
      ),
    ));
    model.prepare(_paidOrder);

    await model.loadReasons();

    expect(model.state.reasonStatus, OrderReturnReasonStatus.failed);
    expect(model.state.status, OrderReturnRequestStatus.ready);
    expect(model.state.reasons, isEmpty);
    model.dispose();
  });
}

final class _ReasonApi implements CommerceApi {
  const _ReasonApi({required this.reasons, required this.request});

  final Future<OrderReturnView> Function(OrderReturnRequestBody body) request;
  final Future<ReturnReasonListView> Function(int? limit, int? offset) reasons;

  @override
  Future<ReturnReasonListView> returnReasons({int? limit, int? offset}) =>
      reasons(limit, offset);

  @override
  Future<OrderReturnView> requestOrderReturn(OrderReturnRequestBody body) =>
      request(body);

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unused API method');
}

ReturnReasonListView _page(
  List<ReturnReasonView> reasons,
  int count,
  int offset,
) =>
    ReturnReasonListView(
      returnReasons: reasons,
      count: count,
      limit: 1,
      offset: offset,
    );

final _damaged = ReturnReasonView(
  id: 'reason_damaged',
  value: 'damaged',
  label: 'Damaged',
  createdAt: returnInstant,
  updatedAt: returnInstant,
);
final _wrongSize = ReturnReasonView(
  id: 'reason_wrong_size',
  value: 'wrong_size',
  label: 'Wrong size',
  createdAt: returnInstant,
  updatedAt: returnInstant,
);
final _response = OrderReturnView(
  id: 'return_1',
  displayId: 1,
  orderId: 'order_1',
  status: OrderReturnStatus.requested,
  itemQuantity: 1,
  requestedAt: returnInstant,
);
final Order _paidOrder = paidReturnOrder(quantity: 1);
