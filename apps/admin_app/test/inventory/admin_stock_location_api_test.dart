import 'dart:convert';
import 'dart:io';

import 'package:admin_app/src/inventory/admin_stock_location_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late AdminStockLocationApi api;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_respond);
    final dio = Dio()..options.headers['authorization'] = 'Bearer admin-token';
    api = AdminStockLocationApi(
      dio,
      baseUrl: 'http://${server.address.address}:${server.port}',
    );
  });

  tearDown(() => server.close(force: true));

  test('uses the dedicated authenticated locations contract', () async {
    final page = await api.list('morrow', 20, 0);

    expect(page.count, 1);
    expect(page.stockLocations.single.address1, '1 Morrow Lane');
    expect(page.stockLocations.single.countryCode, 'dk');
  });
}

Future<void> _respond(HttpRequest request) async {
  expect(request.headers.value('authorization'), 'Bearer admin-token');
  expect(request.uri.queryParameters, {
    'q': 'morrow',
    'limit': '20',
    'offset': '0',
  });
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({
    'stock_locations': [
      {
        'id': 'sloc_main',
        'name': 'Morrow Warehouse',
        'address_1': '1 Morrow Lane',
        'city': 'Copenhagen',
        'postal_code': '1050',
        'country_code': 'dk',
      },
    ],
    'count': 1,
    'limit': 20,
    'offset': 0,
  }));
  await request.response.close();
}
