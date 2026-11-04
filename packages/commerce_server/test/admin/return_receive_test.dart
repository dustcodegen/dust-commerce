import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:test/test.dart';

import 'order_detail_fixture.dart';
import 'return_fixture.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start(seedStore: true);
    await seedOrderDetail(harness);
    await seedAdminReturns(harness);
  });
  tearDown(() => harness.stop());

  test('receipt requires a proven admin bearer', () async {
    final request = harness.client.post('/admin/returns/ret_requested/receive')
      ..json(_body([_item('reti_cup', quantity: 1)]));

    (await request.send()).assertUnauthorized();
  });

  test('atomically receives and restocks only intact units', () async {
    final request = harness.client.post('/admin/returns/ret_requested/receive')
      ..bearer(await harness.adminToken())
      ..json(_body([
        _item('reti_cup', damaged: 1),
        _item('reti_shirt', quantity: 2),
      ], noNotification: true));

    final response = await request.send();

    response.assertOk();
    final returned = AdminReturn.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(returned.status, AdminReturnStatus.received);
    expect(returned.receivedAt.isSome, isTrue);
    expect(returned.noNotification, isTrue);
    expect(returned.items.first.receivedQuantity, 1);
    expect(returned.items.first.damagedQuantity, 1);
    expect(returned.items.last.receivedQuantity, 2);
    expect(await _stock(harness, 'var_cup'), 4);
    expect(await _stock(harness, 'var_shirt_m'), 9);
  });

  test('does not restock an unmanaged variant', () async {
    await harness.raw(
      "UPDATE product_variants SET manage_inventory = 0 "
      "WHERE id = 'var_shirt_m'",
    );
    final request = harness.client.post('/admin/returns/ret_requested/receive')
      ..bearer(await harness.adminToken())
      ..json(_body([_item('reti_shirt', quantity: 2)]));

    (await request.send()).assertOk();

    expect(await _stock(harness, 'var_shirt_m'), 7);
  });

  test('partial receipt remains eligible for later units', () async {
    final first = harness.client.post('/admin/returns/ret_requested/receive')
      ..bearer(await harness.adminToken())
      ..json(_body([_item('reti_shirt', quantity: 1)]));

    final firstResponse = await first.send();

    firstResponse.assertOk();
    final partial = AdminReturn.fromJson(
      firstResponse.json! as Map<String, Object?>,
    );
    expect(partial.status, AdminReturnStatus.partiallyReceived);
    expect(partial.items.last.receivedQuantity, 1);

    final second = harness.client.post('/admin/returns/ret_requested/receive')
      ..bearer(await harness.adminToken())
      ..json(_body([
        _item('reti_cup', quantity: 1),
        _item('reti_shirt', quantity: 1),
      ]));
    final completed = AdminReturn.fromJson(
      (await second.send()).json! as Map<String, Object?>,
    );
    expect(completed.status, AdminReturnStatus.received);
  });

  test('invalid quantities and foreign items roll back every update', () async {
    final token = await harness.adminToken();
    for (final items in [
      <Map<String, Object?>>[],
      [_item('reti_cup', quantity: 2)],
      [_item('reti_cup', quantity: 1), _item('reti_received', quantity: 1)],
    ]) {
      final request =
          harness.client.post('/admin/returns/ret_requested/receive')
            ..bearer(token)
            ..json(_body(items));
      (await request.send()).assertUnprocessable();
    }

    final rows = await harness.raw(
      "SELECT SUM(received_quantity) FROM return_items "
      "WHERE return_id = 'ret_requested'",
    );
    expect(rows.single.readIndex<int>(0), 0);
    expect(await _stock(harness, 'var_cup'), 4);
    expect(await _stock(harness, 'var_shirt_m'), 7);

    final terminal = harness.client.post('/admin/returns/ret_received/receive')
      ..bearer(token)
      ..json(_body([_item('reti_received', quantity: 1)]));
    (await terminal.send()).assertUnprocessable();
  });
}

Future<int> _stock(AdminHarness harness, String variantId) async {
  final rows = await harness.raw(
    "SELECT inventory_quantity FROM product_variants WHERE id = '$variantId'",
  );
  return rows.single.readIndex<int>(0);
}

Map<String, Object?> _body(
  List<Map<String, Object?>> items, {
  bool noNotification = false,
}) =>
    {'items': items, 'no_notification': noNotification};

Map<String, Object?> _item(
  String id, {
  int quantity = 0,
  int damaged = 0,
}) =>
    {'id': id, 'quantity': quantity, 'damaged_quantity': damaged};
