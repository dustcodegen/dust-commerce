import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  test('keeps Medusa return quantities on orders, not cart lines', () {
    const detail = OrderLineItemDetail(
      deliveredQuantity: 5,
      returnRequestedQuantity: 2,
      returnReceivedQuantity: 1,
      returnDismissedQuantity: 1,
    );
    const item = OrderLineItem(
      id: 'item_1',
      variantId: 'variant_1',
      productId: 'product_1',
      productHandle: 'shirt',
      title: 'Shirt',
      unitPrice: Money(amount: 2000, currencyCode: 'usd'),
      quantity: 5,
      detail: detail,
    );

    expect(detail.returnableQuantity, 1);
    expect(OrderLineItem.fromJson(item.toJson()), item);
    expect(item.toJson(), containsPair('detail', detail.toJson()));
    expect(
      LineItem(
        id: item.id,
        variantId: item.variantId,
        productId: item.productId,
        productHandle: item.productHandle,
        title: item.title,
        unitPrice: item.unitPrice,
        quantity: item.quantity,
      ).toJson(),
      isNot(contains('detail')),
    );
  });
}
