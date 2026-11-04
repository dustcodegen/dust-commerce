import 'dart:convert';
import 'dart:io';

import 'package:admin_app/src/order/admin_order_detail_api.dart';
import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

import 'admin_order_detail_fixture.dart';

void main() {
  late HttpServer server;
  late Uri origin;
  late int responseStatus;

  setUp(() async {
    responseStatus = HttpStatus.ok;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    origin = Uri.parse('http://${server.address.address}:${server.port}');
    server.listen((request) => _respond(request, responseStatus));
  });
  tearDown(() => server.close(force: true));

  test('generated client sends Medusa delivery path and body', () async {
    final api = AdminOrderDetailApi(Dio(), baseUrl: origin.toString());

    final order = await api.markDelivered('ord_detail', 'ful_01', _command);

    expect(order.fulfillmentStatus,
        AdminOrderFulfillmentStatus.partiallyDelivered);
    expect(order.fulfillments.single.deliveredAt, isA<Some<DateTime>>());
  });

  test('delivery state publishes the refreshed typed order', () async {
    final detail = _viewModel(origin);

    final delivered =
        await detail.markDelivered('ord_detail', 'ful_01', _command);

    expect(delivered, isTrue);
    expect(detail.state.status, AdminOrderDetailStatus.ready);
    final order = (detail.state.order as Some<AdminOrderDetail>).value;
    expect(order.fulfillments.single.deliveredAt, isA<Some<DateTime>>());
  });

  test('notification failure keeps the loaded order and safe copy', () async {
    final detail = _viewModel(origin);
    await detail.load('ord_detail');
    responseStatus = HttpStatus.serviceUnavailable;

    expect(
      await detail.markDelivered('ord_detail', 'ful_01', _command),
      isFalse,
    );

    expect(detail.state.order, isA<Some<AdminOrderDetail>>());
    expect(
      detail.state.failure,
      const Some('Delivery notification is not configured.'),
    );
  });
}

AdminOrderDetailViewModel _viewModel(Uri origin) => AdminOrderDetailViewModel(
      AdminOrderDetailViewModelArgs(
        api: AdminOrderDetailApi(Dio(), baseUrl: origin.toString()),
      ),
    );

Future<void> _respond(HttpRequest request, int responseStatus) async {
  request.response.headers.contentType = ContentType.json;
  if (request.method == 'GET') {
    request.response.write(jsonEncode(adminOrderDetailJson));
  } else {
    expect(
      request.uri.path,
      '/admin/orders/ord_detail/fulfillments/ful_01/mark-as-delivered',
    );
    expect(
        jsonDecode(await utf8.decoder.bind(request).join()), _command.toJson());
    request.response.statusCode = responseStatus;
    request.response.write(jsonEncode(responseStatus == HttpStatus.ok
        ? adminDeliveredOrderDetailJson
        : <String, Object?>{'error': 'safe'}));
  }
  await request.response.close();
}

const _command = AdminMarkFulfillmentDelivered(noNotification: true);
