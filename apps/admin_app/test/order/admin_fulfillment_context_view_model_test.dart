import 'dart:convert';
import 'dart:io';

import 'package:admin_app/src/order/admin_fulfillment_context_state.dart';
import 'package:admin_app/src/order/admin_fulfillment_context_view_model.dart';
import 'package:admin_app/src/order/admin_order_detail_api.dart';
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

  test('loads locations and methods, then reloads for a new location',
      () async {
    final model = AdminFulfillmentContextViewModel(
      AdminFulfillmentContextViewModelArgs(api: _api(origin, true)),
    );

    await model.load('reg_eu', preferredLocationId: const Some('sloc_backup'));

    expect(model.state.status, AdminFulfillmentContextStatus.ready);
    expect(model.state.selectedLocationId, const Some('sloc_backup'));
    expect(model.state.shippingOptions.single.id, 'ship_backup');

    await model.selectLocation('sloc_main');

    expect(model.state.selectedLocationId, const Some('sloc_main'));
    expect(model.state.shippingOptions.single.id, 'ship_eu_standard');
  });

  test('maps an expired Admin session to safe form state', () async {
    final model = AdminFulfillmentContextViewModel(
      AdminFulfillmentContextViewModelArgs(api: _api(origin, false)),
    );

    await model.load('reg_eu');

    expect(model.state.status, AdminFulfillmentContextStatus.failed);
    expect(
      model.state.failure,
      const Some('Your admin session has expired.'),
    );
  });
}

AdminOrderDetailApi _api(Uri origin, bool authorized) {
  final dio = Dio();
  if (authorized) dio.options.headers['authorization'] = 'Bearer admin-token';
  return AdminOrderDetailApi(dio, baseUrl: origin.toString());
}

Future<void> _respond(HttpRequest request) async {
  request.response.headers.contentType = ContentType.json;
  if (request.headers.value('authorization') != 'Bearer admin-token') {
    request.response.statusCode = HttpStatus.unauthorized;
  } else if (request.uri.path == '/admin/stock-locations') {
    request.response.write(jsonEncode({
      'stock_locations': [
        {'id': 'sloc_main', 'name': 'Morrow Warehouse'},
        {'id': 'sloc_backup', 'name': 'Backup Warehouse'},
      ],
      'count': 2,
      'limit': 100,
      'offset': 0,
    }));
  } else if (request.uri.path == '/admin/shipping-options') {
    final backup =
        request.uri.queryParameters['stock_location_id'] == 'sloc_backup';
    request.response.write(jsonEncode({
      'shipping_options': [
        {
          'id': backup ? 'ship_backup' : 'ship_eu_standard',
          'name': backup ? 'Backup delivery' : 'Standard shipping',
          'shipping_profile_id': 'sp_default',
        },
      ],
      'count': 1,
      'limit': 100,
      'offset': 0,
    }));
  } else {
    request.response.statusCode = HttpStatus.notFound;
  }
  await request.response.close();
}
