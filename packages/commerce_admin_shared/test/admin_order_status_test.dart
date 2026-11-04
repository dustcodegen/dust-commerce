import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:test/test.dart';

void main() {
  test('order status codec supports Medusa archived status', () {
    const codec = AdminOrderStatusCodec();

    expect(codec.deserialize('archived'), AdminOrderStatus.archived);
    expect(codec.serialize(AdminOrderStatus.archived), 'archived');
  });
}
