import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test('paid but undelivered orders do not expose a return selection', () {
    final order = paidReturnOrder();
    final model = OrderReturnViewModel(
      const OrderReturnViewModelArgs(api: _UnusedApi()),
    );

    model.prepare(order.copyWith(
      fulfillmentStatus: OrderFulfillmentStatus.notFulfilled,
      items: [
        order.items.single.copyWith(
          detail: order.items.single.detail.copyWith(deliveredQuantity: 0),
        ),
      ],
    ));

    expect(model.state.status, OrderReturnRequestStatus.failed);
    expect(model.state.failure, const Some(OrderReturnFailure.notEligible));
    model.dispose();
  });
}

final class _UnusedApi implements CommerceApi {
  const _UnusedApi();

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('No API call expected');
}
