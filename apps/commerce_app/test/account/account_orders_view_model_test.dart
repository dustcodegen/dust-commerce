import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts one complete order-history response', () async {
    final model = AccountOrdersViewModel(
      AccountOrdersViewModelArgs(
        api: _OrdersApi(() async => const OrderListView(orders: [], count: 0)),
      ),
    );

    await model.load();

    expect(model.state.status, AccountOrdersStatus.ready);
    expect(model.state.hasLoaded, isTrue);
    expect(model.state.orders, isEmpty);
    expect(model.state.failure, const None<AccountOrdersFailure>());
    model.dispose();
  });

  test('reset rejects an in-flight response from a previous identity',
      () async {
    final deferred = Completer<OrderListView>();
    final model = AccountOrdersViewModel(
      AccountOrdersViewModelArgs(api: _OrdersApi(() => deferred.future)),
    );

    final loading = model.load();
    model.reset();
    deferred.complete(const OrderListView(orders: [], count: 0));
    await loading;

    expect(model.state, const AccountOrdersState());
    model.dispose();
  });

  test('classifies an expired session without storing display copy', () async {
    final request = RequestOptions(path: '/store/orders');
    final error = DioException(
      requestOptions: request,
      response: Response<void>(requestOptions: request, statusCode: 401),
    );
    final model = AccountOrdersViewModel(
      AccountOrdersViewModelArgs(
        api: _OrdersApi(() => Future<OrderListView>.error(error)),
      ),
    );

    await model.load();

    expect(model.state.status, AccountOrdersStatus.failed);
    expect(model.state.hasLoaded, isFalse);
    expect(
      model.state.failure,
      const Some(AccountOrdersFailure.unauthorized),
    );
    model.dispose();
  });
}

final class _OrdersApi implements CommerceApi {
  const _OrdersApi(this.list);

  final Future<OrderListView> Function() list;

  @override
  Future<OrderListView> orders() => list();

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unused API method');
}
