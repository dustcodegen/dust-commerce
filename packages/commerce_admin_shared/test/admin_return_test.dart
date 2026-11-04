import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('decodes an allowlisted return page with explicit absence', () {
    final page = AdminReturnList.fromJson({
      'returns': [
        {
          'id': 'ret_01',
          'order_id': 'order_01',
          'display_id': 42,
          'status': 'requested',
          'no_notification': false,
          'refund_amount': null,
          'requested_at': '2026-09-14T10:00:00.000Z',
          'received_at': null,
          'canceled_at': null,
          'created_at': '2026-09-14T10:00:00.000Z',
          'updated_at': '2026-09-14T10:01:00.000Z',
          'items': [
            {
              'id': 'reti_01',
              'order_item_id': 'orditem_01',
              'quantity': 2,
              'received_quantity': 0,
              'damaged_quantity': 0,
              'reason_id': 'reason_size',
              'note': null,
            },
          ],
        },
      ],
      'count': 1,
      'limit': 20,
      'offset': 0,
    });

    final value = page.returns.single;
    expect(value.status, AdminReturnStatus.requested);
    expect(value.requestedAt.isUtc, isTrue);
    expect(value.refundAmount, const None<int>());
    expect(value.receivedAt, const None<DateTime>());
    expect(value.items.single.reasonId, const Some('reason_size'));
    expect(value.items.single.note, const None<String>());
  });

  test('round trips partially received merchant quantities', () {
    final value = AdminReturn.fromJson({
      'id': 'ret_02',
      'order_id': 'order_02',
      'display_id': 43,
      'status': 'partially_received',
      'no_notification': true,
      'refund_amount': 1200,
      'requested_at': '2026-09-14T10:00:00.000Z',
      'received_at': '2026-09-14T11:00:00.000Z',
      'canceled_at': null,
      'created_at': '2026-09-14T10:00:00.000Z',
      'updated_at': '2026-09-14T11:00:00.000Z',
      'items': [
        {
          'id': 'reti_02',
          'order_item_id': 'orditem_02',
          'quantity': 3,
          'received_quantity': 2,
          'damaged_quantity': 1,
          'reason_id': null,
          'note': 'Opened package',
        },
      ],
    });

    final decoded = AdminReturn.fromJson(value.toJson());
    expect(decoded, value);
    expect(decoded.receivedAt, Some(DateTime.utc(2026, 9, 14, 11)));
    expect(decoded.items.single.receivedQuantity, 2);
    expect(decoded.items.single.damagedQuantity, 1);
  });

  test('encodes one atomic intact and damaged receipt operation', () {
    const body = AdminReceiveReturn(
      items: [
        AdminReceiveReturnItem(
          id: 'reti_02',
          quantity: 1,
          damagedQuantity: 1,
        ),
      ],
      noNotification: true,
    );

    expect(body.toJson(), {
      'items': [
        {
          'damaged_quantity': 1,
          'id': 'reti_02',
          'quantity': 1,
        },
      ],
      'no_notification': true,
    });
    expect(AdminReceiveReturn.fromJson(body.toJson()), body);
  });
}
