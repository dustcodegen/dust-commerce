import 'dart:convert';
import 'dart:io';

import 'package:admin_app/src/order/admin_return_api.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
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

  test('generated client uses Dio auth and Medusa return filters', () async {
    final dio = Dio()..options.headers['authorization'] = 'Bearer admin-token';
    final api = AdminReturnApi(dio, baseUrl: origin.toString());

    final page = await api.list('ord_detail', 'requested', 20, 0);

    expect(page.count, 1);
    expect(page.returns.single.id, 'ret_01');
    expect(page.returns.single.status, AdminReturnStatus.requested);
    expect(page.returns.single.items.single.quantity, 2);
  });

  test('generated client posts the typed atomic receipt command', () async {
    final dio = Dio()..options.headers['authorization'] = 'Bearer admin-token';
    final api = AdminReturnApi(dio, baseUrl: origin.toString());

    final returned = await api.receive(
      'ret_01',
      const AdminReceiveReturn(
        items: [
          AdminReceiveReturnItem(
            id: 'reti_01',
            quantity: 1,
            damagedQuantity: 1,
          ),
        ],
        noNotification: true,
      ),
    );

    expect(returned.status, AdminReturnStatus.received);
    expect(returned.items.single.receivedQuantity, 2);
  });
}

Future<void> _respond(HttpRequest request) async {
  expect(request.headers.value('authorization'), 'Bearer admin-token');
  request.response.headers.contentType = ContentType.json;
  if (request.method == 'GET') {
    expect(request.uri.path, '/admin/returns');
    expect(request.uri.queryParameters, {
      'order_id': 'ord_detail',
      'status': 'requested',
      'limit': '20',
      'offset': '0',
    });
    request.response.write(jsonEncode({
      'returns': [_returned],
      'count': 1,
      'limit': 20,
      'offset': 0,
    }));
  } else {
    expect(request.uri.path, '/admin/returns/ret_01/receive');
    expect(await utf8.decoder.bind(request).join(), contains('reti_01'));
    request.response.write(jsonEncode({
      ..._returned,
      'status': 'received',
      'received_at': '2026-09-14T11:00:00.000Z',
      'items': [
        {
          ...(_returned['items']! as List<Object?>).single!
              as Map<String, Object?>,
          'received_quantity': 2,
          'damaged_quantity': 1,
        },
      ],
    }));
  }
  await request.response.close();
}

const _returned = <String, Object?>{
  'id': 'ret_01',
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
  'items': [
    {
      'id': 'reti_01',
      'order_item_id': 'item_01',
      'quantity': 2,
      'received_quantity': 0,
      'damaged_quantity': 0,
      'reason_id': null,
      'note': null,
    },
  ],
};
