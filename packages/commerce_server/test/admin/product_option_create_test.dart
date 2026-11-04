import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('global option creation requires a proven admin bearer', () async {
    final response = await (harness.client.post('/admin/product-options')
          ..json(_body()))
        .send();

    response.assertUnauthorized();
  });

  test('creates a global option and its ordered values atomically', () async {
    final token = await harness.adminToken();
    final response = await (harness.client.post('/admin/product-options')
          ..bearer(token)
          ..json(_body()))
        .send();

    response.assertCreated();
    final option = response.json! as Map<String, Object?>;
    expect(option['title'], 'Material');
    expect(option['is_exclusive'], false);
    expect(option['products'], isEmpty);
    expect(
      (option['values']! as List<Object?>)
          .map((item) => (item! as Map<String, Object?>)['value'])
          .toList(),
      ['Cotton', 'Linen'],
    );
  });

  test('duplicate title and values do not leave partial rows', () async {
    final token = await harness.adminToken();
    final titleConflict = await (harness.client.post('/admin/product-options')
          ..bearer(token)
          ..json(_body(title: 'Size')))
        .send();
    final invalid = await (harness.client.post('/admin/product-options')
          ..bearer(token)
          ..json(_body(values: ['Cotton', 'Cotton'])))
        .send();

    titleConflict.assertConflict();
    invalid.assertUnprocessable();
    final rows = await harness.raw(
      "SELECT count(*) FROM product_options WHERE title = 'Material'",
    );
    expect(rows.single.readIndex<int>(0), 0);
  });
}

Map<String, Object?> _body({
  String title = 'Material',
  List<String> values = const ['Cotton', 'Linen'],
}) =>
    {'title': title, 'values': values};
