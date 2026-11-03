import 'package:commerce_app/route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transfer decision routes retain the capability path segments', () {
    final accept = parseCommerceRoute(
      Uri.parse('/order/order_qa/transfer/demo-capability/accept'),
    );
    final decline = parseCommerceRoute(
      Uri.parse('/order/order_qa/transfer/demo-capability/decline'),
    );

    expect(accept, isA<OrderTransferAcceptRoute>());
    expect((accept as OrderTransferAcceptRoute).id, 'order_qa');
    expect(accept.token, 'demo-capability');
    expect(accept.requiresAuth, isFalse);
    expect(decline, isA<OrderTransferDeclineRoute>());
    expect((decline as OrderTransferDeclineRoute).id, 'order_qa');
    expect(decline.token, 'demo-capability');
    expect(decline.requiresAuth, isFalse);
  });
}
