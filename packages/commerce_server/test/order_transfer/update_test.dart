import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late TransferScenario scenario;

  setUp(() async => scenario = await TransferScenario.start());
  tearDown(() async => scenario.stop());

  test('public token acceptance moves order ownership', () async {
    final order = await scenario.ownedOrder();
    (await scenario.request(order.orderId, order.targetToken))
        .assertStatus(202);
    final capability = scenario.mailer.attempts.single.token;

    final accepted = await scenario.decide(order.orderId, capability, 'accept');

    accepted.assertOk();
    expect((accepted.json! as Map<String, Object?>)['status'], 'accepted');
    final targetRead = scenario.harness.client
        .get('/store/orders/${order.orderId}')
      ..bearer(order.targetToken);
    (await targetRead.send()).assertOk();
    final previousRead = scenario.harness.client
        .get('/store/orders/${order.orderId}')
      ..bearer(order.ownerToken);
    (await previousRead.send()).assertNotFound();
  });

  test('public token decline preserves current ownership', () async {
    final order = await scenario.ownedOrder();
    (await scenario.request(order.orderId, order.targetToken))
        .assertStatus(202);
    final capability = scenario.mailer.attempts.single.token;

    final declined =
        await scenario.decide(order.orderId, capability, 'decline');

    declined.assertOk();
    expect((declined.json! as Map<String, Object?>)['status'], 'declined');
    final ownerRead = scenario.harness.client
        .get('/store/orders/${order.orderId}')
      ..bearer(order.ownerToken);
    (await ownerRead.send()).assertOk();
  });

  test('wrong token reveals no transfer or order existence', () async {
    final order = await scenario.ownedOrder();
    (await scenario.request(order.orderId, order.targetToken))
        .assertStatus(202);

    (await scenario.decide(order.orderId, 'wrong-token', 'accept'))
        .assertNotFound();
  });

  test('same decision is idempotent and opposite decision conflicts', () async {
    final order = await scenario.ownedOrder();
    (await scenario.request(order.orderId, order.targetToken))
        .assertStatus(202);
    final capability = scenario.mailer.attempts.single.token;

    (await scenario.decide(order.orderId, capability, 'accept')).assertOk();
    (await scenario.decide(order.orderId, capability, 'accept')).assertOk();
    (await scenario.decide(order.orderId, capability, 'decline'))
        .assertConflict();
  });

  test('expired capability is rejected and finalised', () async {
    await scenario.stop();
    var now = DateTime.utc(2100, 1, 1, 12);
    scenario = await TransferScenario.start(now: () => now);
    final order = await scenario.ownedOrder();
    (await scenario.request(order.orderId, order.targetToken))
        .assertStatus(202);
    final capability = scenario.mailer.attempts.single.token;
    now = now.add(const Duration(hours: 25));

    (await scenario.decide(order.orderId, capability, 'accept'))
        .assertNotFound();
    final rows = await queryRaw(
      'SELECT status, delivery_token FROM order_transfers',
      [],
    ).fetch(scenario.harness.database.connection as Executor);
    expect(rows.single.readIndex<String>(0), 'expired');
    expect(rows.single.readIndexNullable<String>(1), isNull);
  });

  test('empty decision capability is rejected as validation failure', () async {
    final order = await scenario.ownedOrder();

    (await scenario.decide(order.orderId, '', 'accept')).assertUnprocessable();
  });
}
