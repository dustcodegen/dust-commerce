import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('image variant batches require a proven admin bearer', () async {
    final request = harness.client.post(
      '/admin/products/prod_sweatpants/images/img_sweatpants_1/variants/batch',
    )..json({'add': <String>[], 'remove': <String>[]});

    (await request.send()).assertUnauthorized();
  });

  test('adds and removes image variants with detail readback', () async {
    final token = await harness.adminToken();
    final add = harness.client.post(_path)
      ..bearer(token)
      ..json({
        'add': ['var_sweatpants_s', 'var_sweatpants_m'],
        'remove': <String>[],
      });

    final added = await add.send();

    added.assertOk();
    expect(added.json, {
      'added': ['var_sweatpants_s', 'var_sweatpants_m'],
      'removed': <String>[],
    });
    expect(await _variantIds(harness, token), [
      'var_sweatpants_m',
      'var_sweatpants_s',
    ]);

    final remove = harness.client.post(_path)
      ..bearer(token)
      ..json({
        'add': <String>[],
        'remove': ['var_sweatpants_s'],
      });
    final removed = await remove.send();

    removed.assertOk();
    expect(removed.json, {
      'added': <String>[],
      'removed': ['var_sweatpants_s'],
    });
    expect(await _variantIds(harness, token), ['var_sweatpants_m']);
  });

  test('rejects conflicting or cross-product variants atomically', () async {
    final token = await harness.adminToken();
    final conflict = harness.client.post(_path)
      ..bearer(token)
      ..json({
        'add': ['var_sweatpants_s'],
        'remove': ['var_sweatpants_s'],
      });
    final foreign = harness.client.post(_path)
      ..bearer(token)
      ..json({
        'add': ['var_tshirt_s_black'],
        'remove': <String>[],
      });

    (await conflict.send()).assertUnprocessable();
    (await foreign.send()).assertUnprocessable();
    expect(
      await harness.raw('''
SELECT * FROM product_image_variants
WHERE image_id = 'img_sweatpants_1'
'''),
      isEmpty,
    );
  });
}

const _path =
    '/admin/products/prod_sweatpants/images/img_sweatpants_1/variants/batch';

Future<List<Object?>> _variantIds(AdminHarness harness, String token) async {
  final request = harness.client.get('/admin/products/prod_sweatpants')
    ..bearer(token);
  final response = await request.send();
  response.assertOk();
  final product = response.json! as Map<String, Object?>;
  final images = product['images']! as List<Object?>;
  final first = images.first! as Map<String, Object?>;
  return first['variant_ids']! as List<Object?>;
}
