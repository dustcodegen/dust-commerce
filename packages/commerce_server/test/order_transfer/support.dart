import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';

import '../checkout/support.dart';

final class RecordingTransferMailer implements OrderTransferMailer {
  RecordingTransferMailer({this.available = true, this.fail = false});

  final bool available;
  bool fail;
  final List<OrderTransferMail> attempts = [];

  @override
  bool get isAvailable => available;

  @override
  Future<void> send(OrderTransferMail mail) async {
    attempts.add(mail);
    if (fail) throw StateError('simulated SMTP refusal');
  }
}

final class TransferScenario {
  TransferScenario(this.harness, this.mailer);

  static Future<TransferScenario> start({
    RecordingTransferMailer? mailer,
    DateTime Function()? now,
  }) async {
    final delivery = mailer ?? RecordingTransferMailer();
    return TransferScenario(
      await CheckoutHarness.start(
        orderTransferMailer: delivery,
        now: now,
      ),
      delivery,
    );
  }

  final CheckoutHarness harness;
  final RecordingTransferMailer mailer;

  OrderTransferDeps serviceDeps() {
    final executor = harness.database.executor;
    return OrderTransferDeps(
      database: harness.database,
      reads: OrderTransferReadRepository(executor),
      creates: OrderTransferCreateRepository(executor),
      updates: OrderTransferUpdateRepository(executor),
      clock: Clock(
        now: () => DateTime.utc(2100, 1, 1, 12),
        nextId: () => 'transfer_${Tokens.issue()}',
      ),
      mailer: mailer,
    );
  }

  Future<
      ({
        String orderId,
        String ownerId,
        String ownerToken,
        String targetId,
        String targetToken,
      })> ownedOrder() async {
    final owner = await harness.account('owner@example.com');
    final target = await harness.account('target@example.com');
    final cart = await harness.cartWith('var_small', token: owner.token);
    final placed = await harness.checkout(cart, token: owner.token);
    placed.assertCreated();
    final order = Order.fromJson(placed.json! as Map<String, Object?>);
    return (
      orderId: order.id,
      ownerId: owner.customerId,
      ownerToken: owner.token,
      targetId: target.customerId,
      targetToken: target.token,
    );
  }

  Future<TestResponse> request(String orderId, String token) =>
      (harness.client.post('/store/orders/$orderId/transfer/request')
            ..bearer(token))
          .send();

  Future<TestResponse> decide(
    String orderId,
    String token,
    String decision,
  ) =>
      (harness.client.post('/store/orders/$orderId/transfer/$decision')
            ..json({'token': token}))
          .send();

  Future<void> stop() => harness.stop();
}
