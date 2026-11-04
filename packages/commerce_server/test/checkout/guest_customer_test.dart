import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() async => harness.stop());

  test('guest checkout creates an active guest customer profile', () async {
    final cartId = await harness.cartWith('var_small');
    final placed = await harness.checkout(
      cartId,
      email: 'guest@example.com',
      shipping: harness.address(
        firstName: 'Katherine',
        phone: '+1 555 0100',
      ),
    );

    placed.assertCreated();
    final order = Order.fromJson(placed.json! as Map<String, Object?>);
    final rows = await queryRaw(
      'SELECT email, first_name, last_name, phone, has_account, '
      'created_at, updated_at FROM customers WHERE email = \$1',
      ['guest@example.com'],
    ).fetch(harness.database.connection as Executor);

    expect(order.customerId, isNull);
    expect(rows, hasLength(1));
    expect(rows.single.readIndex<String>(0), 'guest@example.com');
    expect(rows.single.readIndex<String>(1), 'Katherine');
    expect(rows.single.readIndex<String>(2), 'Lovelace');
    expect(rows.single.readIndex<String>(3), '+1 555 0100');
    expect(rows.single.readIndex<int>(4), 0);
    expect(rows.single.readIndex<DateTime>(5), isNotNull);
    expect(rows.single.readIndex<DateTime>(6), isNotNull);
  });

  test('later guest checkout refreshes the same email profile', () async {
    final firstCart = await harness.cartWith('var_small');
    (await harness.checkout(firstCart, email: 'guest@example.com'))
        .assertCreated();
    final secondCart = await harness.cartWith('var_small');
    (await harness.checkout(
      secondCart,
      email: 'guest@example.com',
      shipping: harness.address(firstName: 'Grace'),
    ))
        .assertCreated();

    final rows = await queryRaw(
      'SELECT COUNT(*), MAX(first_name) FROM customers '
      'WHERE email = \$1 AND has_account = 0 AND deleted_at IS NULL',
      ['guest@example.com'],
    ).fetch(harness.database.connection as Executor);

    expect(rows.single.readIndex<int>(0), 1);
    expect(rows.single.readIndex<String>(1), 'Grace');
  });
}
