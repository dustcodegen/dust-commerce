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

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    origin = Uri.parse('http://${server.address.address}:${server.port}');
    server.listen(_respond);
  });
  tearDown(() => server.close(force: true));

  test('generated detail client decodes typed optional values', () async {
    final api = _api(origin, authorized: true);

    final order = await api.order('ord_detail');

    expect(order.displayId, 1001);
    expect(order.createdAt.isUtc, isTrue);
    expect(order.shippingName, const Some('Standard shipping'));
    expect(order.billingAddress, const None<AdminOrderAddress>());
    expect(order.items.single.thumbnail, const None<String>());
    expect(
      order.paymentRecordStatus,
      const Some(AdminOrderPaymentRecordStatus.captured),
    );
  });

  test('detail state publishes one allowlisted order', () async {
    final detail = AdminOrderDetailViewModel(
      AdminOrderDetailViewModelArgs(api: _api(origin, authorized: true)),
    );

    await detail.load('ord_detail');

    expect(detail.state.status, AdminOrderDetailStatus.ready);
    expect(detail.state.order, isA<Some<AdminOrderDetail>>());
    expect(
      (detail.state.order as Some<AdminOrderDetail>).value.total,
      5400,
    );
  });

  test('detail state maps missing and expired sessions safely', () async {
    final missing = AdminOrderDetailViewModel(
      AdminOrderDetailViewModelArgs(api: _api(origin, authorized: true)),
    );
    await missing.load('missing');
    expect(missing.state.failure, const Some('This order no longer exists.'));

    final expired = AdminOrderDetailViewModel(
      AdminOrderDetailViewModelArgs(api: _api(origin, authorized: false)),
    );
    await expired.load('ord_detail');
    expect(
      expired.state.failure,
      const Some('Your admin session has expired.'),
    );
  });

  test('create fulfillment publishes the refreshed typed order', () async {
    final detail = AdminOrderDetailViewModel(
      AdminOrderDetailViewModelArgs(api: _api(origin, authorized: true)),
    );
    await detail.load('ord_detail');

    final created = await detail.createFulfillment(
      'ord_detail',
      _fulfillment,
    );

    expect(created, isTrue);
    expect(detail.state.status, AdminOrderDetailStatus.ready);
    final order = (detail.state.order as Some<AdminOrderDetail>).value;
    expect(order.fulfillmentStatus,
        AdminOrderFulfillmentStatus.partiallyFulfilled);
    expect(order.fulfillments.single.providerId, 'manual');
  });

  test('create failure preserves the loaded order and maps safe copy',
      () async {
    final detail = AdminOrderDetailViewModel(
      AdminOrderDetailViewModelArgs(api: _api(origin, authorized: true)),
    );
    await detail.load('ord_detail');
    const invalid = AdminCreateFulfillment(
      items: [AdminCreateFulfillmentItem(id: 'invalid', quantity: 1)],
      locationId: 'sloc_main',
      noNotification: true,
      shippingOptionIdValue: 'ship_eu_standard',
    );

    expect(await detail.createFulfillment('ord_detail', invalid), isFalse);

    expect(detail.state.status, AdminOrderDetailStatus.failed);
    expect(detail.state.order, isA<Some<AdminOrderDetail>>());
    expect(
      detail.state.failure,
      const Some('Fulfillment command is invalid.'),
    );

    const notify = AdminCreateFulfillment(
      items: [AdminCreateFulfillmentItem(id: 'item_cup', quantity: 1)],
      locationId: 'sloc_main',
      noNotification: false,
      shippingOptionIdValue: 'ship_eu_standard',
    );
    expect(await detail.createFulfillment('ord_detail', notify), isFalse);
    expect(
      detail.state.failure,
      const Some('Fulfillment notification is not configured.'),
    );
  });
}

AdminOrderDetailApi _api(Uri origin, {required bool authorized}) {
  final dio = Dio();
  if (authorized) dio.options.headers['authorization'] = 'Bearer test-token';
  return AdminOrderDetailApi(dio, baseUrl: origin.toString());
}

Future<void> _respond(HttpRequest request) async {
  request.response.headers.contentType = ContentType.json;
  if (request.headers.value('authorization') != 'Bearer test-token') {
    request.response.statusCode = HttpStatus.unauthorized;
  } else if (request.method == 'POST') {
    final json = jsonDecode(await utf8.decoder.bind(request).join())
        as Map<String, Object?>;
    final items = json['items']! as List<Object?>;
    final item = items.single! as Map<String, Object?>;
    if (json['no_notification'] == false) {
      request.response.statusCode = HttpStatus.serviceUnavailable;
    } else if (item['id'] == 'invalid') {
      request.response.statusCode = HttpStatus.unprocessableEntity;
    } else {
      expect(json, _fulfillment.toJson());
      request.response.write(jsonEncode(adminFulfilledOrderDetailJson));
    }
  } else if (request.uri.path == '/admin/orders/ord_detail') {
    request.response.write(jsonEncode(adminOrderDetailJson));
  } else {
    request.response.statusCode = HttpStatus.notFound;
  }
  await request.response.close();
}

const _fulfillment = AdminCreateFulfillment(
  items: [AdminCreateFulfillmentItem(id: 'item_cup', quantity: 1)],
  locationId: 'sloc_main',
  noNotification: true,
  shippingOptionIdValue: 'ship_eu_standard',
);
