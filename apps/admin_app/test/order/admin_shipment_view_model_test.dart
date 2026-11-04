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

  test('generated client sends Medusa shipment path and body', () async {
    final api = AdminOrderDetailApi(Dio(), baseUrl: origin.toString());

    final order = await api.createShipment('ord_detail', 'ful_01', _shipment);

    expect(
        order.fulfillmentStatus, AdminOrderFulfillmentStatus.partiallyShipped);
    expect(order.fulfillments.single.shippedAt, isA<Some<DateTime>>());
    expect(order.fulfillments.single.labels.single.trackingNumber, 'TRACK-123');
  });

  test('shipment state publishes the refreshed typed order', () async {
    final detail = AdminOrderDetailViewModel(
      AdminOrderDetailViewModelArgs(
        api: AdminOrderDetailApi(Dio(), baseUrl: origin.toString()),
      ),
    );

    final created = await detail.createShipment(
      'ord_detail',
      'ful_01',
      _shipment,
    );

    expect(created, isTrue);
    expect(detail.state.status, AdminOrderDetailStatus.ready);
    final order = (detail.state.order as Some<AdminOrderDetail>).value;
    expect(order.fulfillments.single.markedShippedBy, const Some('admin_01'));
  });

  test('shipment failure keeps the loaded order and safe copy', () async {
    final detail = AdminOrderDetailViewModel(
      AdminOrderDetailViewModelArgs(
        api: AdminOrderDetailApi(Dio(), baseUrl: origin.toString()),
      ),
    );
    await detail.load('ord_detail');
    responseStatus = HttpStatus.unprocessableEntity;

    expect(
      await detail.createShipment('ord_detail', 'ful_01', _shipment),
      isFalse,
    );

    expect(detail.state.order, isA<Some<AdminOrderDetail>>());
    expect(detail.state.failure, const Some('Shipment command is invalid.'));
  });
}

Future<void> _respond(HttpRequest request, int responseStatus) async {
  request.response.headers.contentType = ContentType.json;
  if (request.method == 'GET') {
    request.response.write(jsonEncode(adminOrderDetailJson));
  } else {
    expect(
      request.uri.path,
      '/admin/orders/ord_detail/fulfillments/ful_01/shipments',
    );
    expect(
      jsonDecode(await utf8.decoder.bind(request).join()),
      _shipment.toJson(),
    );
    request.response.statusCode = responseStatus;
    if (responseStatus == HttpStatus.ok) {
      request.response.write(jsonEncode(adminShippedOrderDetailJson));
    } else {
      request.response.write(jsonEncode({'error': 'safe'}));
    }
  }
  await request.response.close();
}

const _shipment = AdminCreateShipment(
  items: [AdminCreateShipmentItem(id: 'item_cup', quantity: 1)],
  labels: [
    AdminCreateShipmentLabel(
      trackingNumber: 'TRACK-123',
      trackingUrl: 'https://carrier.example/TRACK-123',
      labelUrl: '#',
    ),
  ],
  noNotification: true,
);
