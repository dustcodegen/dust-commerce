import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product update requires a proven admin bearer', () async {
    final request = harness.client.patch('/admin/products/prod_sweatpants')
      ..json(_body());

    (await request.send()).assertUnauthorized();
  });

  test('product update replaces supported fields and returns fresh detail',
      () async {
    await harness.raw(
      "UPDATE products SET updated_at = TIMESTAMPTZ '2000-01-01T00:00:00.000Z' "
      "WHERE id = 'prod_sweatpants'",
    );
    final token = await harness.adminToken();
    final request = harness.client.patch('/admin/products/prod_sweatpants')
      ..bearer(token)
      ..json(_body(
        title: '  Everyday Trousers  ',
        handle: 'everyday-trousers',
        subtitle: '  A softer name  ',
        description: '  Built for daily wear.  ',
        material: '  Cotton twill  ',
        status: 'draft',
        discountable: false,
      ));

    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json['title'], 'Everyday Trousers');
    expect(json['handle'], 'everyday-trousers');
    expect(json['description'], 'Built for daily wear.');
    expect(json['discountable'], isFalse);
    expect(json['material'], 'Cotton twill');
    expect(json['status'], 'draft');
    expect(json['subtitle'], 'A softer name');
    expect(json['images'], hasLength(2));
    final stored = await harness.raw(
      "SELECT title, handle, description, material, status, updated_at, "
      "subtitle, discountable "
      "FROM products WHERE id = 'prod_sweatpants'",
    );
    expect(stored.single.readIndex<String>(0), 'Everyday Trousers');
    expect(stored.single.readIndex<String>(1), 'everyday-trousers');
    expect(stored.single.readIndex<String>(2), 'Built for daily wear.');
    expect(stored.single.readIndex<String>(3), 'Cotton twill');
    expect(stored.single.readIndex<String>(4), 'draft');
    expect(stored.single.readIndex<DateTime>(5),
        isNot(DateTime.parse('2000-01-01T00:00:00.000Z')));
    expect(stored.single.readIndex<String>(6), 'A softer name');
    expect(stored.single.readIndex<int>(7), 0);
  });

  test('empty optional values clear subtitle, material, and description',
      () async {
    await harness.raw(
      "UPDATE products SET subtitle = 'Old subtitle' "
      "WHERE id = 'prod_sweatpants'",
    );
    final token = await harness.adminToken();
    final request = harness.client.patch('/admin/products/prod_sweatpants')
      ..bearer(token)
      ..json(_body(description: '  ', material: '', subtitle: ''));

    (await request.send()).assertOk();
    final stored = await harness.raw(
      "SELECT subtitle, description, material FROM products "
      "WHERE id = 'prod_sweatpants'",
    );
    expect(stored.single.readIndexNullable<String>(0), isNull);
    expect(stored.single.readIndexNullable<String>(1), isNull);
    expect(stored.single.readIndexNullable<String>(2), isNull);
  });

  test('duplicate handle is a conflict and leaves the product unchanged',
      () async {
    final token = await harness.adminToken();
    final request = harness.client.patch('/admin/products/prod_sweatpants')
      ..bearer(token)
      ..json(_body(title: 'Must not persist', handle: 't-shirt'));

    (await request.send()).assertConflict();
    final stored = await harness.raw(
      "SELECT title, handle FROM products WHERE id = 'prod_sweatpants'",
    );
    expect(stored.single.readIndex<String>(0), 'Relaxed Sweatpants');
    expect(stored.single.readIndex<String>(1), 'sweatpants');
  });

  test('invalid general fields are rejected before persistence', () async {
    final token = await harness.adminToken();
    final request = harness.client.patch('/admin/products/prod_sweatpants')
      ..bearer(token)
      ..json(_body(title: '   ', handle: 'Not A Slug'));

    (await request.send()).assertUnprocessable();
  });

  test('unknown product returns not found', () async {
    final token = await harness.adminToken();
    final request = harness.client.patch('/admin/products/prod_missing')
      ..bearer(token)
      ..json(_body());

    (await request.send()).assertNotFound();
  });
}

Map<String, Object?> _body({
  String title = 'Relaxed Sweatpants',
  String handle = 'sweatpants',
  String? description = 'Relaxed everyday sweatpants in soft brushed cotton.',
  String? material = 'Cotton',
  String? subtitle,
  String status = 'published',
  bool discountable = true,
}) =>
    {
      'title': title,
      'handle': handle,
      'description': description,
      'discountable': discountable,
      'material': material,
      'status': status,
      'subtitle': subtitle,
    };
