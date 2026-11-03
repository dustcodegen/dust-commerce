import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'list_support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late CatalogOptionRepository options;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_options');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    options = CatalogOptionRepository(database.executor);
    await seedCatalogList(database);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('returns direct response rows with stable value ids', () async {
    final result = ok(await options.list(10, 0));

    expect(result, hasLength(1));
    expect(result.single.id, 'opt_size');
    expect(result.single.values.map((value) => value.id), [
      'optval_small',
      'optval_large',
    ]);
  });
}
