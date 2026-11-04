import 'dart:convert';
import 'dart:io';

import 'package:admin_app/src/order/admin_order_detail_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late AdminOrderDetailApi api;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_respond);
    final dio = Dio()..options.headers['authorization'] = 'Bearer admin-token';
    api = AdminOrderDetailApi(
      dio,
      baseUrl: 'http://${server.address.address}:${server.port}',
    );
  });
  tearDown(() => server.close(force: true));

  test('generated client lists typed fulfillment choices through Dio auth',
      () async {
    final locations = await api.stockLocations('', 20, 0);
    final options = await api.fulfillmentShippingOptions(
      'sloc_main',
      'reg_eu',
      '',
      20,
      0,
    );

    expect(locations.stockLocations.single.id, 'sloc_main');
    expect(options.shippingOptions.single.shippingProfileId, 'sp_default');
  });
}

Future<void> _respond(HttpRequest request) async {
  expect(request.headers.value('authorization'), 'Bearer admin-token');
  request.response.headers.contentType = ContentType.json;
  if (request.uri.path == '/admin/stock-locations') {
    expect(
        request.uri.queryParameters, {'q': '', 'limit': '20', 'offset': '0'});
    request.response.write(jsonEncode({
      'stock_locations': [
        {'id': 'sloc_main', 'name': 'Morrow Warehouse'},
      ],
      'count': 1,
      'limit': 20,
      'offset': 0,
    }));
  } else if (request.uri.path == '/admin/shipping-options') {
    expect(request.uri.queryParameters, {
      'stock_location_id': 'sloc_main',
      'region_id': 'reg_eu',
      'q': '',
      'limit': '20',
      'offset': '0',
    });
    request.response.write(jsonEncode({
      'shipping_options': [
        {
          'id': 'ship_eu_standard',
          'name': 'Standard shipping',
          'shipping_profile_id': 'sp_default',
        },
      ],
      'count': 1,
      'limit': 20,
      'offset': 0,
    }));
  } else {
    request.response.statusCode = HttpStatus.notFound;
  }
  await request.response.close();
}
