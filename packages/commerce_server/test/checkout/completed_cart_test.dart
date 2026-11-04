import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() async => harness.stop());

  test('checkout empties and closes the ordered cart', () async {
    final cartId = await harness.cartWith('var_small');

    (await harness.checkout(cartId)).assertCreated();

    final rows = await queryRaw(
      r'SELECT (SELECT COUNT(*) FROM line_items WHERE cart_id = $1), '
      r'completed_at FROM carts WHERE id = $1',
      [cartId],
    ).fetch(harness.database.connection as Executor);
    expect(rows.single.readIndex<int>(0), 0);
    expect(rows.single.readIndex<DateTime?>(1), isNotNull);
    (await harness.client.get('/store/carts/$cartId').send()).assertNotFound();
  });
}
