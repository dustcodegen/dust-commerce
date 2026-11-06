import 'dart:convert';
import 'dart:io';

import 'package:admin_app/src/order/admin_order_detail_api.dart';
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

  test('generated refund-reason mutations keep typed Dio contracts', () async {
    final api = AdminOrderDetailApi(
      Dio()..options.headers['authorization'] = 'Bearer admin-token',
      baseUrl: origin.toString(),
    );
    final created = await api.createRefundReason(const AdminCreateRefundReason(
      label: 'Wrong size',
      code: 'wrong_size',
      descriptionValue: 'Customer selected the wrong size.',
    ));
    final updated = await api.updateRefundReason(
      created.id,
      const AdminUpdateRefundReason(
        label: 'Wrong fit',
        code: 'wrong_fit',
        descriptionValue: null,
      ),
    );
    final deleted = await api.deleteRefundReason(updated.id);

    expect(created.code, 'wrong_size');
    expect(updated.label, 'Wrong fit');
    expect(
      deleted,
      const AdminRefundReasonDeleted(id: 'reason_new', deleted: true),
    );
  });
}

Future<void> _respond(HttpRequest request) async {
  request.response.headers.contentType = ContentType.json;
  expect(request.headers.value('authorization'), 'Bearer admin-token');
  if (request.uri.path == '/admin/refund-reasons' && request.method == 'POST') {
    expect(
      jsonDecode(await utf8.decoder.bind(request).join()),
      const AdminCreateRefundReason(
        label: 'Wrong size',
        code: 'wrong_size',
        descriptionValue: 'Customer selected the wrong size.',
      ).toJson(),
    );
    request.response.statusCode = HttpStatus.created;
    request.response.write(jsonEncode(_newReasonJson));
  } else if (request.uri.path == '/admin/refund-reasons/reason_new' &&
      request.method == 'PATCH') {
    expect(
      jsonDecode(await utf8.decoder.bind(request).join()),
      const AdminUpdateRefundReason(
        label: 'Wrong fit',
        code: 'wrong_fit',
        descriptionValue: null,
      ).toJson(),
    );
    request.response.write(jsonEncode(_updatedReasonJson));
  } else if (request.uri.path == '/admin/refund-reasons/reason_new' &&
      request.method == 'DELETE') {
    request.response.write(jsonEncode({'id': 'reason_new', 'deleted': true}));
  } else {
    request.response.statusCode = HttpStatus.notFound;
  }
  await request.response.close();
}

const _newReasonJson = <String, Object?>{
  'id': 'reason_new',
  'label': 'Wrong size',
  'code': 'wrong_size',
  'description': 'Customer selected the wrong size.',
};

const _updatedReasonJson = <String, Object?>{
  'id': 'reason_new',
  'label': 'Wrong fit',
  'code': 'wrong_fit',
  'description': null,
};
