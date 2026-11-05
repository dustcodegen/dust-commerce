import 'dart:io';

import 'package:admin_app/src/inventory/admin_stock_location_api.dart';
import 'package:admin_app/src/inventory/admin_stock_location_view_model.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late Uri origin;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    origin = Uri.parse('http://${server.address.address}:${server.port}');
    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      if (request.uri.queryParameters['q'] == 'missing') {
        request.response.statusCode = 500;
      } else {
        request.response.write(
            '''{"stock_locations":[{"id":"sloc_main","name":"Morrow Warehouse","address_1":"1 Morrow Lane","country_code":"dk"}],"count":21,"limit":20,"offset":${request.uri.queryParameters['offset']}}''');
      }
      await request.response.close();
    });
  });

  tearDown(() => server.close(force: true));

  test('loads query state and exposes following-page bounds', () async {
    final model = AdminStockLocationViewModel(
      AdminStockLocationViewModelArgs(
        api: AdminStockLocationApi(Dio(), baseUrl: origin.toString()),
      ),
    );

    await model.search('warehouse');

    expect(model.state.query, 'warehouse');
    expect(model.state.stockLocations.single.name, 'Morrow Warehouse');
    expect(model.state.hasNext, isTrue);
  });

  test('maps a transport failure to safe display state', () async {
    final model = AdminStockLocationViewModel(
      AdminStockLocationViewModelArgs(
        api: AdminStockLocationApi(Dio(), baseUrl: origin.toString()),
      ),
    );

    await model.search('missing');

    expect(
      model.state.failure,
      const Some('Unable to load stock locations. Try again.'),
    );
  });
}
