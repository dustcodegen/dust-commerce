import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'product_import_fixture.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product import confirmation requires the route-level admin bearer',
      () async {
    final request =
        harness.client.post('/admin/products/import/unknown/confirm');
    (await request.send()).assertUnauthorized();
  });

  test('staged product imports remain private to their admin owner', () async {
    final ownerToken = await harness.adminToken();
    final transactionId = await previewProductImport(
      harness,
      ownerToken,
      newOnlyProductImportCsv,
    );
    var id = 0;
    final other = await bootstrapAdmin(
      harness.database,
      const AdminCredentials(
        email: 'other@example.com',
        password: AdminHarness.password,
      ),
      nextId: () => 'other_${++id}',
      passwordWork: PasswordWorkLimiter(),
    );
    if (other case Ok()) {
      // The second identity exists only to prove object-level ownership.
    } else {
      fail('Second admin bootstrap failed: $other');
    }
    final signIn = await harness.signIn(email: 'other@example.com');
    signIn.assertOk();
    final token = (signIn.json! as Map<String, Object?>)['token']! as String;
    final request = harness.client.post(
      '/admin/products/import/$transactionId/confirm',
    )..bearer(token);

    (await request.send()).assertNotFound();
  });

  test('atomically creates and updates complete storefront product graphs',
      () async {
    final token = await harness.adminToken();
    final transactionId = await previewProductImport(
      harness,
      token,
      completeProductImportCsv,
    );

    final confirmed = harness.client.post(
      '/admin/products/import/$transactionId/confirm',
    )..bearer(token);
    final response = await confirmed.send();

    response
      ..assertStatus(202)
      ..assertBodyEmpty();
    final capResponse = await harness.client
        .get('/store/products/imported-cap?currency=usd')
        .send();
    capResponse.assertOk();
    final cap = Product.fromJson(capResponse.json! as Map<String, Object?>);
    expect(cap.title, 'Imported Cap');
    expect(cap.variants, hasLength(2));
    expect(cap.cheapestIn('usd'), Money.of(1800, 'usd'));
    expect(
      cap.images.map((image) => image.url),
      [importedCapFront, importedCapBack],
    );
    expect(cap.tags.map((tag) => tag.value), contains('Imported'));
    expect(cap.options.single.title, 'Size');

    final updated = await harness.raw('''
SELECT title, subtitle, material, weight, status
FROM products WHERE id = 'prod_tshirt'
''');
    expect(updated.single.readIndex<String>(0), 'Imported Essential Tee');
    expect(updated.single.readIndex<String>(1), 'Updated by CSV');
    expect(updated.single.readIndex<String>(2), 'Organic cotton');
    expect(updated.single.readIndex<int>(3), 250);
    expect(updated.single.readIndex<String>(4), 'published');
    final variant = await harness.raw('''
SELECT material, barcode FROM product_variants
WHERE id = 'var_tshirt_s_black'
''');
    expect(variant.single.readIndex<String>(0), 'Jersey');
    expect(variant.single.readIndex<String>(1), 'TEE-S-BLACK');
    final price = await harness.raw('''
SELECT amount FROM variant_prices
WHERE variant_id = 'var_tshirt_s_black' AND currency_code = 'usd'
''');
    expect(price.single.readIndex<int>(0), 1600);
    final staged = await harness.raw(
      "SELECT status FROM product_imports WHERE id = '$transactionId'",
    );
    expect(staged.single.readIndex<String>(0), 'completed');

    final repeated = harness.client.post(
      '/admin/products/import/$transactionId/confirm',
    )..bearer(token);
    (await repeated.send()).assertConflict();
  });

  test('partial update CSV preserves every omitted catalogue field', () async {
    final token = await harness.adminToken();
    const csv =
        'Product Id,Product Handle,Product Title,Variant Id,Variant Title\r\n'
        'prod_tshirt,t-shirt,Renamed Tee,var_tshirt_s_black,S / Black\r\n';
    final transactionId = await previewProductImport(harness, token, csv);
    final request = harness.client.post(
      '/admin/products/import/$transactionId/confirm',
    )..bearer(token);

    (await request.send()).assertStatus(202);
    final product = await harness.raw('''
SELECT title, description, thumbnail, weight, status, discountable
FROM products WHERE id = 'prod_tshirt'
''');
    expect(product.single.readIndex<String>(0), 'Renamed Tee');
    expect(product.single.readIndex<String>(1), contains('soft cotton'));
    expect(product.single.readIndex<String>(2), isNotEmpty);
    expect(product.single.readIndex<int>(3), 400);
    expect(product.single.readIndex<String>(4), 'published');
    expect(product.single.readIndex<int>(5), 1);
    final variant = await harness.raw('''
SELECT sku, inventory_quantity, manage_inventory, allow_backorder
FROM product_variants WHERE id = 'var_tshirt_s_black'
''');
    expect(variant.single.readIndex<String>(0), 'TSHIRT-S-BLACK');
    expect(variant.single.readIndex<int>(1), 20);
    expect(variant.single.readIndex<int>(2), 1);
    expect(variant.single.readIndex<int>(3), 0);
  });

  test('expired or conflicting imports change no catalogue rows', () async {
    final token = await harness.adminToken();
    final expiredId = await previewProductImport(
      harness,
      token,
      newOnlyProductImportCsv,
    );
    await harness.raw(
      "UPDATE product_imports SET expires_at = '2020-01-01T00:00:00.000Z' "
      "WHERE id = '$expiredId'",
    );
    final expired = harness.client.post(
      '/admin/products/import/$expiredId/confirm',
    )..bearer(token);
    (await expired.send()).assertConflict();

    final conflictId = await previewProductImport(
      harness,
      token,
      conflictingSkuProductImportCsv,
    );
    final conflict = harness.client.post(
      '/admin/products/import/$conflictId/confirm',
    )..bearer(token);
    (await conflict.send()).assertConflict();
    expect(
      await harness.raw(
        "SELECT id FROM products WHERE handle IN ('new-cap', 'bad-sku')",
      ),
      isEmpty,
    );
  });
}
