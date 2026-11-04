import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  final region = Region.of(
    id: 'reg_eu',
    name: 'Europe',
    currencyCode: 'eur',
    taxRate: 2000,
    countries: const ['de'],
  );

  final address = Address.of(
    firstName: 'Ada',
    lastName: 'Lovelace',
    line1: '12 Analytical Way',
    city: 'Berlin',
    postalCode: '10115',
    countryCode: 'DE',
  );

  LineItem line({int unitPrice = 1000, int quantity = 2}) => LineItem.of(
        id: 'item_1',
        variantId: 'variant_1',
        productId: 'prod_1',
        productHandle: 't-shirt',
        title: 'T-Shirt',
        unitPrice: Money.of(unitPrice, 'eur'),
        quantity: quantity,
      );

  Cart cart({List<LineItem>? items}) => Cart.of(
        id: 'cart_1',
        region: region,
        items: items ?? [line()],
        email: 'ada@example.com',
      );

  Order placed({Cart? from}) => Order.fromCart(
        id: 'order_1',
        displayId: 1,
        cart: from ?? cart(),
        shippingAddress: address,
        placedAt: DateTime.utc(2026, 9, 5),
      );

  group('Order.fromCart', () {
    test('freezes the totals rather than recomputing them', () {
      final order = placed();

      expect(order.subtotal, Money.of(2000, 'eur'));
      expect(order.displayId, 1);
      expect(order.tax, Money.of(400, 'eur'));
      expect(order.total, Money.of(2400, 'eur'));
    });

    test('copies the lines, so a later cart change cannot reach it', () {
      final source = cart();
      final order = placed(from: source);

      final emptied = source.withoutLine('item_1');

      expect(emptied.items, isEmpty);
      expect(order.items, hasLength(1));
      expect(order.items.single.unitPrice, Money.of(1000, 'eur'));
      expect(order.items.single, isA<OrderLineItem>());
    });

    test('refuses an empty cart, which is nothing to order', () {
      expect(
        () => placed(from: Cart.of(id: 'cart_1', region: region)),
        throwsArgumentError,
      );
    });

    test('refuses a cart with no email to reach the buyer on', () {
      final anonymous = Cart.of(id: 'c', region: region, items: [line()]);

      expect(() => placed(from: anonymous), throwsArgumentError);
    });

    test('starts pending, and is not yet paid', () {
      final order = placed();

      expect(order.status, OrderStatus.pending);
      expect(order.fulfillmentStatus, OrderFulfillmentStatus.notFulfilled);
      expect(order.paymentStatus, PaymentStatus.awaiting);
      expect(order.isPaid, isFalse);
    });

    test('bills to the shipping address unless told otherwise', () {
      expect(placed().billingAddress, address);
    });
  });

  group('lifecycle', () {
    test('capturing payment does not complete or deliver the order', () {
      final captured = placed().captured();

      expect(captured.paymentStatus, PaymentStatus.captured);
      expect(captured.isPaid, isTrue);
      expect(captured.status, OrderStatus.pending);
      expect(captured.items.single.detail.deliveredQuantity, 0);
    });

    test('cancelling a pending order leaves the payment awaiting', () {
      final canceled = placed().canceled();

      expect(canceled.status, OrderStatus.canceled);
      expect(canceled.paymentStatus, PaymentStatus.awaiting);
    });

    test('refuses to cancel an order already paid', () {
      expect(() => placed().captured().canceled(), throwsStateError);
    });

    test('refuses to capture an order already canceled', () {
      expect(() => placed().canceled().captured(), throwsStateError);
    });

    test('refuses money and cancellation changes after archival', () {
      final archived = placed().copyWith(status: OrderStatus.archived);

      expect(archived.captured, throwsStateError);
      expect(archived.canceled, throwsStateError);
    });
  });

  group('json', () {
    test('round-trips through the generated codec', () {
      expect(Order.fromJson(placed().toJson()), placed());
    });

    test('round-trips the explicit payment receipt', () {
      final order = placed().copyWith(
        payment: OrderPayment(
          providerId: 'manual',
          amount: Money.of(2400, 'eur'),
          createdAt: DateTime.utc(2026, 9, 5, 12, 30),
        ),
      );

      expect(Order.fromJson(order.toJson()), order);
      expect(order.toJson()['payment'], isA<Map<String, Object?>>());
    });

    test('encodes status as its wire name', () {
      expect(placed().toJson()['status'], 'pending');
      expect(placed().toJson()['payment_status'], 'awaiting');
      expect(placed().toJson()['fulfillment_status'], 'not_fulfilled');
    });

    test('round-trips Medusa archived status', () {
      final archived = placed().copyWith(status: OrderStatus.archived);

      expect(Order.fromJson(archived.toJson()), archived);
      expect(archived.toJson()['status'], 'archived');
    });
  });
}
