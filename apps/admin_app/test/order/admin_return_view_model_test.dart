import 'dart:convert';
import 'dart:io';

import 'package:admin_app/src/order/admin_return_api.dart';
import 'package:admin_app/src/order/admin_return_state.dart';
import 'package:admin_app/src/order/admin_return_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late Uri origin;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    origin = Uri.parse('http://${server.address.address}:${server.port}');
    server.listen(_respond);
  });
  tearDown(() => server.close(force: true));

  test('loads only requested returns for one order', () async {
    final returns = AdminReturnViewModel(
      AdminReturnViewModelArgs(api: _api(origin, authorized: true)),
    );

    await returns.loadRequested('ord_detail');

    expect(returns.state.status, AdminReturnLoadStatus.ready);
    expect(returns.state.returns.single.id, 'ret_requested');
    expect(returns.state.failure, const None<String>());
  });

  test('maps an expired Admin session without transport state', () async {
    final returns = AdminReturnViewModel(
      AdminReturnViewModelArgs(api: _api(origin, authorized: false)),
    );

    await returns.loadRequested('ord_detail');

    expect(returns.state.status, AdminReturnLoadStatus.failed);
    expect(
      returns.state.failure,
      const Some('Your admin session has expired.'),
    );
  });

  test('successful receipt removes the terminal return', () async {
    final returns = AdminReturnViewModel(
      AdminReturnViewModelArgs(api: _api(origin, authorized: true)),
    );
    await returns.loadRequested('ord_detail');

    await returns.receive('ret_requested', _receipt);

    expect(returns.state.status, AdminReturnLoadStatus.ready);
    expect(returns.state.returns, isEmpty);
    expect(returns.state.failure, const None<String>());
  });

  test('invalid receipt keeps the loaded return and exposes safe failure',
      () async {
    final returns = AdminReturnViewModel(
      AdminReturnViewModelArgs(api: _api(origin, authorized: true)),
    );
    await returns.loadRequested('ord_detail');

    await returns.receive('invalid', _receipt);

    expect(returns.state.status, AdminReturnLoadStatus.failed);
    expect(returns.state.returns.single.id, 'ret_requested');
    expect(
      returns.state.failure,
      const Some('Return receipt quantities are invalid.'),
    );
  });
}

AdminReturnApi _api(Uri origin, {required bool authorized}) {
  final dio = Dio();
  if (authorized) dio.options.headers['authorization'] = 'Bearer admin-token';
  return AdminReturnApi(dio, baseUrl: origin.toString());
}

Future<void> _respond(HttpRequest request) async {
  request.response.headers.contentType = ContentType.json;
  if (request.headers.value('authorization') != 'Bearer admin-token') {
    request.response.statusCode = HttpStatus.unauthorized;
  } else if (request.method == 'POST' && request.uri.path.contains('invalid')) {
    request.response.statusCode = HttpStatus.unprocessableEntity;
  } else if (request.method == 'POST') {
    request.response.write(jsonEncode({
      ...((_page['returns']! as List<Object?>).first! as Map<String, Object?>),
      'status': 'received',
      'received_at': '2026-09-14T11:00:00.000Z',
    }));
  } else {
    expect(request.uri.queryParameters['order_id'], 'ord_detail');
    expect(request.uri.queryParameters['status'], 'requested');
    request.response.write(jsonEncode(_page));
  }
  await request.response.close();
}

const _page = <String, Object?>{
  'returns': [
    {
      'id': 'ret_requested',
      'order_id': 'ord_detail',
      'display_id': 1,
      'status': 'requested',
      'no_notification': false,
      'refund_amount': null,
      'requested_at': '2026-09-14T10:00:00.000Z',
      'received_at': null,
      'canceled_at': null,
      'created_at': '2026-09-14T10:00:00.000Z',
      'updated_at': '2026-09-14T10:00:00.000Z',
      'items': <Object?>[],
    },
  ],
  'count': 1,
  'limit': 20,
  'offset': 0,
};

const _receipt = AdminReceiveReturn(
  items: [
    AdminReceiveReturnItem(
      id: 'reti_01',
      quantity: 1,
      damagedQuantity: 0,
    ),
  ],
  noNotification: true,
);
