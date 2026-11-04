import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads and appends bounded return pages in server order', () async {
    final offsets = <int>[];
    final model = OrderReturnHistoryViewModel(
      OrderReturnHistoryViewModelArgs(
        api: _HistoryApi((id, limit, offset) async {
          offsets.add(offset ?? 0);
          return offset == 1
              ? _page([_first], count: 2, offset: 1)
              : _page([_second], count: 2, offset: 0);
        }),
      ),
    );

    await model.load('order_1');
    await model.loadMore();

    expect(offsets, [0, 1]);
    expect(model.state.orderId, const Some('order_1'));
    expect(model.state.returns, [_second, _first]);
    expect(model.state.count, 2);
    expect(model.state.offset, 2);
    expect(model.state.hasMore, isFalse);
    expect(model.state.status, OrderReturnHistoryStatus.ready);
    model.dispose();
  });

  test('deduplicates a shifted page while consuming its server offset',
      () async {
    var calls = 0;
    final model = OrderReturnHistoryViewModel(
      OrderReturnHistoryViewModelArgs(
        api: _HistoryApi((_, __, offset) async {
          calls++;
          return offset == 1
              ? _page([_second], count: 2, offset: 1)
              : _page([_second], count: 2, offset: 0);
        }),
      ),
    );

    await model.load('order_1');
    await model.loadMore();

    expect(calls, 2);
    expect(model.state.returns, [_second]);
    expect(model.state.offset, 2);
    expect(model.state.hasMore, isFalse);
    model.dispose();
  });

  for (final entry in {
    401: OrderReturnHistoryFailure.sessionExpired,
    404: OrderReturnHistoryFailure.unavailable,
    500: OrderReturnHistoryFailure.retryable,
  }.entries) {
    test('classifies ${entry.key} without exposing transport state', () async {
      final request = RequestOptions(path: '/store/orders/order_1/returns');
      final model = OrderReturnHistoryViewModel(
        OrderReturnHistoryViewModelArgs(
          api: _HistoryApi((_, __, ___) => Future.error(DioException(
                requestOptions: request,
                response: Response<void>(
                  requestOptions: request,
                  statusCode: entry.key,
                ),
              ))),
        ),
      );

      await model.load('order_1');

      expect(model.state.status, OrderReturnHistoryStatus.failed);
      expect(model.state.failure, Some(entry.value));
      model.dispose();
    });
  }

  test('reset ignores an in-flight page from the previous identity', () async {
    final pending = Completer<OrderReturnListView>();
    final model = OrderReturnHistoryViewModel(
      OrderReturnHistoryViewModelArgs(
        api: _HistoryApi((_, __, ___) => pending.future),
      ),
    );

    final load = model.load('order_1');
    model.reset();
    pending.complete(_page([_first], count: 1, offset: 0));
    await load;

    expect(model.state, const OrderReturnHistoryState());
    model.dispose();
  });

  test('a created return refreshes the matching loaded history', () async {
    var calls = 0;
    final refreshed = Completer<void>();
    final model = OrderReturnHistoryViewModel(
      OrderReturnHistoryViewModelArgs(
        api: _HistoryApi((_, __, ___) async {
          calls++;
          if (calls == 2) refreshed.complete();
          return calls == 1
              ? _page(const [], count: 0, offset: 0)
              : _page([_second], count: 1, offset: 0);
        }),
      ),
    );
    await model.load('order_1');

    model.record(_second);
    await refreshed.future;
    await Future<void>.delayed(Duration.zero);

    expect(calls, 2);
    expect(model.state.returns, [_second]);
    model.dispose();
  });
}

final class _HistoryApi implements OrderReturnHistoryApi {
  const _HistoryApi(this.call);

  final Future<OrderReturnListView> Function(
    String id,
    int? limit,
    int? offset,
  ) call;

  @override
  Future<OrderReturnListView> returns(
    String id, {
    int? limit,
    int? offset,
  }) =>
      call(id, limit, offset);
}

OrderReturnListView _page(
  List<OrderReturnView> returns, {
  required int count,
  required int offset,
}) =>
    OrderReturnListView(
      returns: returns,
      count: count,
      limit: 10,
      offset: offset,
    );

final _first = OrderReturnView(
  id: 'return_1',
  displayId: 1,
  orderId: 'order_1',
  status: OrderReturnStatus.received,
  itemQuantity: 1,
  requestedAt: DateTime.utc(2026, 9, 14, 12),
);

final _second = OrderReturnView(
  id: 'return_2',
  displayId: 2,
  orderId: 'order_1',
  status: OrderReturnStatus.requested,
  itemQuantity: 2,
  requestedAt: DateTime.utc(2026, 9, 14, 13),
);
