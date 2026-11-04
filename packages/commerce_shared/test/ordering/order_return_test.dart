import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('return request uses Medusa item keys and optional values', () {
    const request = OrderReturnRequestBody(
      orderId: 'order_1',
      items: [
        OrderReturnItemInput(
          itemId: 'item_1',
          quantity: 2,
          reasonIdValue: 'reason_damaged',
          noteValue: 'Box crushed',
        ),
      ],
      noteValue: 'Please email a label',
    );

    expect(request.validate().isValid, isTrue);
    expect(request.items.single.reasonId, const Some('reason_damaged'));
    expect(request.toJson(), {
      'order_id': 'order_1',
      'items': [
        {
          'id': 'item_1',
          'quantity': 2,
          'reason_id': 'reason_damaged',
          'note': 'Box crushed',
        },
      ],
      'note': 'Please email a label',
    });
  });

  test('return request rejects missing order, items and positive quantity', () {
    const empty = OrderReturnRequestBody(orderId: '', items: []);
    const zero = OrderReturnRequestBody(
      orderId: 'order_1',
      items: [OrderReturnItemInput(itemId: 'item_1', quantity: 0)],
    );

    expect(empty.validate().isValid, isFalse);
    expect(zero.validate().isValid, isFalse);
  });

  test('return response keeps typed status and timestamp', () {
    final response = OrderReturnView(
      id: 'return_1',
      displayId: 1,
      orderId: 'order_1',
      status: OrderReturnStatus.requested,
      itemQuantity: 2,
      requestedAt: DateTime.utc(2026, 9, 14, 12),
    );

    expect(OrderReturnView.fromJson(response.toJson()), response);
    expect(response.toJson()['requested_at'], '2026-09-14T12:00:00.000Z');
  });

  test('return history keeps paging and typed entries', () {
    final response = OrderReturnView(
      id: 'return_2',
      displayId: 2,
      orderId: 'order_1',
      status: OrderReturnStatus.partiallyReceived,
      itemQuantity: 3,
      requestedAt: DateTime.utc(2026, 9, 14, 13),
    );
    final page = OrderReturnListView(
      returns: [response],
      count: 4,
      limit: 2,
      offset: 2,
    );

    expect(OrderReturnListView.fromJson(page.toJson()), page);
    expect(page.returns.single.status, OrderReturnStatus.partiallyReceived);
  });
}
