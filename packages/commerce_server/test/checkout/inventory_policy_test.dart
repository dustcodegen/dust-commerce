import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() async => harness.stop());

  test('checkout leaves unmanaged inventory unchanged', () async {
    await queryExecute(
      'UPDATE product_variants SET manage_inventory = 0 '
      "WHERE id = 'var_large'",
      const [],
    ).execute(harness.database.executor);
    final cartId = await harness.cartWith('var_large');

    (await harness.checkout(cartId)).assertCreated();

    expect(await harness.stockOf('var_large'), 2);
  });
}
