import 'dart:convert';

import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product import preview requires the route-level admin bearer',
      () async {
    final request = harness.client.post('/admin/products/import')
      ..bytes(
        _multipart(_validCsv),
        contentType: 'multipart/form-data; boundary=import',
      );

    (await request.send()).assertUnauthorized();
  });

  test('stages a Medusa CSV and reports unique creates and updates', () async {
    final before = await harness.raw('SELECT count(*) FROM products');
    final response = await _preview(harness, _validCsv);

    response.assertOk();
    response.assertJsonContains({
      'summary': {'to_create': 1, 'to_update': 1},
    });
    final body = response.json! as Map<String, Object?>;
    expect(body['transaction_id'], isNotEmpty);

    final after = await harness.raw('SELECT count(*) FROM products');
    expect(after.single.readIndex<int>(0), before.single.readIndex<int>(0));
    final staged = await harness.raw('''
SELECT admin_user_id, filename, status, to_create, to_update
FROM product_imports
''');
    expect(staged, hasLength(1));
    expect(staged.single.readIndex<String>(0), 'admin_1');
    expect(staged.single.readIndex<String>(1), 'products.csv');
    expect(staged.single.readIndex<String>(2), 'pending');
    expect(staged.single.readIndex<int>(3), 1);
    expect(staged.single.readIndex<int>(4), 1);
  });

  test('rejects unsupported files and malformed product rows', () async {
    final token = await harness.adminToken();
    final wrongType = harness.client.post('/admin/products/import')
      ..bearer(token)
      ..bytes(
        _multipart(_validCsv, contentType: 'application/json'),
        contentType: 'multipart/form-data; boundary=import',
      );
    (await wrongType.send()).assertUnprocessable();

    final invalid = await _preview(
      harness,
      'Product Id,Product Handle,Product Title\r\n,,Missing handle\r\n',
    );
    invalid.assertUnprocessable();

    final ambiguous = await _preview(
      harness,
      'Product Id,Product Handle,Product Title\r\n'
      'prod_tshirt,sweatpants,Wrong identity\r\n',
    );
    ambiguous.assertUnprocessable();
    expect(await harness.raw('SELECT id FROM product_imports'), isEmpty);
  });
}

const _validCsv =
    'Product Id,Product Handle,Product Title,Variant Id,Variant Title\r\n'
    'prod_tshirt,t-shirt,Essential T-Shirt,var_tshirt_s_black,S / Black\r\n'
    ',new-cap,New Cap,,Small\r\n'
    ',new-cap,New Cap,,Large\r\n';

Future<TestResponse> _preview(AdminHarness harness, String csv) async {
  final token = await harness.adminToken();
  final request = harness.client.post('/admin/products/import')
    ..bearer(token)
    ..bytes(
      _multipart(csv),
      contentType: 'multipart/form-data; boundary=import',
    );
  return request.send();
}

List<int> _multipart(
  String csv, {
  String contentType = 'text/csv',
}) =>
    utf8.encode(
      '--import\r\n'
      'Content-Disposition: form-data; name="file"; filename="products.csv"\r\n'
      'Content-Type: $contentType\r\n\r\n'
      '$csv\r\n'
      '--import--\r\n',
    );
