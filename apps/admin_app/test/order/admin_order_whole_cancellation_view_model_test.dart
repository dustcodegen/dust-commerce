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

  test('whole-order cancellation publishes the refreshed typed order',
      () async {
    final detail = _viewModel(origin);

    final canceled = await detail.cancelOrder('ord_detail');

    expect(canceled, isTrue);
    expect(detail.state.status, AdminOrderDetailStatus.ready);
    final order = (detail.state.order as Some<AdminOrderDetail>).value;
    expect(order.status, AdminOrderStatus.canceled);
    expect(order.paymentStatus, AdminOrderPaymentStatus.refunded);
  });

  test('refused cancellation keeps loaded order and safe copy', () async {
    final detail = _viewModel(origin);
    await detail.load('ord_detail');
    responseStatus = HttpStatus.unprocessableEntity;

    expect(await detail.cancelOrder('ord_detail'), isFalse);

    expect(detail.state.order, isA<Some<AdminOrderDetail>>());
    expect(
      detail.state.failure,
      const Some('This order cannot be canceled in its current state.'),
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
    expect(request.uri.path, '/admin/orders/ord_detail/cancel');
    request.response.statusCode = responseStatus;
    request.response.write(jsonEncode(responseStatus == HttpStatus.ok
        ? <String, Object?>{
            ...adminOrderDetailJson,
            'status': 'canceled',
            'payment_status': 'refunded',
            'payment_record_status': 'canceled',
          }
        : <String, Object?>{'error': 'safe'}));
  }
  await request.response.close();
}
