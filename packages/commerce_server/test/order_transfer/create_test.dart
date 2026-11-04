import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late TransferScenario scenario;

  tearDown(() async => scenario.stop());

  test('authenticated target requests an allowlisted delivered transfer',
      () async {
    scenario = await TransferScenario.start();
    final order = await scenario.ownedOrder();

    final response = await scenario.request(order.orderId, order.targetToken);

    response.assertStatus(202);
    final body = response.json! as Map<String, Object?>;
    expect(response.json, {
      'id': body['id'],
      'order_id': order.orderId,
      'status': 'requested',
      'delivery_status': 'sent',
      'expires_at': '2100-01-02T12:00:00.000Z',
    });
    expect(scenario.mailer.attempts.single.recipient, 'owner@example.com');
    expect(scenario.mailer.attempts.single.orderId, order.orderId);

    final rows = await queryRaw(
      'SELECT token_fingerprint, delivery_token FROM order_transfers',
      [],
    ).fetch(scenario.harness.database.connection as Executor);
    expect(
      rows.single.readIndex<String>(0),
      await Tokens.fingerprint(scenario.mailer.attempts.single.token),
    );
    expect(rows.single.readIndexNullable<String>(1), isNull);
  });

  test('request route requires a valid bearer token', () async {
    scenario = await TransferScenario.start();

    (await scenario.harness.client
            .post('/store/orders/order_1/transfer/request')
            .send())
        .assertUnauthorized();
  });

  test('request hides a missing order', () async {
    scenario = await TransferScenario.start();
    final target = await scenario.harness.account('target@example.com');

    (await scenario.request('missing-order', target.token)).assertNotFound();
    expect(scenario.mailer.attempts, isEmpty);
  });

  test('request rejects a canceled order', () async {
    scenario = await TransferScenario.start();
    final order = await scenario.ownedOrder();
    await queryExecute(
      "UPDATE orders SET status = 'canceled', "
      "canceled_at = '2026-09-14T00:00:00.000Z' WHERE id = \$1",
      [order.orderId],
    ).execute(scenario.harness.database.executor);

    (await scenario.request(order.orderId, order.targetToken))
        .assertUnprocessable();
    expect(scenario.mailer.attempts, isEmpty);
  });

  test('request rejects an order already owned by the target', () async {
    scenario = await TransferScenario.start();
    final order = await scenario.ownedOrder();

    (await scenario.request(order.orderId, order.ownerToken))
        .assertUnprocessable();
    expect(scenario.mailer.attempts, isEmpty);
  });

  test('request fails honestly when email delivery is not configured',
      () async {
    scenario = await TransferScenario.start(
      mailer: RecordingTransferMailer(available: false),
    );
    final order = await scenario.ownedOrder();

    final response = await scenario.request(order.orderId, order.targetToken);

    expect(response.statusCode, 503);
    final rows = await queryRaw('SELECT COUNT(*) FROM order_transfers', [])
        .fetch(scenario.harness.database.connection as Executor);
    expect(rows.single.readIndex<int>(0), 0);
  });

  test('repeating a delivered request is idempotent', () async {
    scenario = await TransferScenario.start();
    final order = await scenario.ownedOrder();

    final first = await scenario.request(order.orderId, order.targetToken);
    final second = await scenario.request(order.orderId, order.targetToken);

    first.assertStatus(202);
    second.assertStatus(202);
    expect(second.json, first.json);
    expect(scenario.mailer.attempts, hasLength(1));
  });

  test('one order cannot target two accounts at the same time', () async {
    scenario = await TransferScenario.start();
    final order = await scenario.ownedOrder();
    final other = await scenario.harness.account('other@example.com');
    (await scenario.request(order.orderId, order.targetToken))
        .assertStatus(202);

    (await scenario.request(order.orderId, other.token)).assertConflict();
    expect(scenario.mailer.attempts, hasLength(1));
  });

  test('failed SMTP work remains retryable with the same capability', () async {
    final mailer = RecordingTransferMailer(fail: true);
    scenario = await TransferScenario.start(mailer: mailer);
    final order = await scenario.ownedOrder();

    final queued = await scenario.request(order.orderId, order.targetToken);
    queued.assertStatus(202);
    expect((queued.json! as Map<String, Object?>)['delivery_status'], 'queued');
    final firstToken = mailer.attempts.single.token;

    mailer.fail = false;
    final delivered = await scenario.request(order.orderId, order.targetToken);
    delivered.assertStatus(202);
    expect(
      (delivered.json! as Map<String, Object?>)['delivery_status'],
      'sent',
    );
    expect(mailer.attempts, hasLength(2));
    expect(mailer.attempts.last.token, firstToken);
  });
}
