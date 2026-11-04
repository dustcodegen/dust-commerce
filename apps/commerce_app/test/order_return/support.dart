import 'package:commerce_shared/commerce_shared.dart';

/// Stable paid-order fixture shared by return ViewModel tests.
Order paidReturnOrder({int quantity = 3, int requestedQuantity = 0}) => Order(
      id: 'order_1',
      displayId: 1,
      email: 'ada@example.com',
      customerId: 'cus_ada',
      region: const Region(
        id: 'reg_us',
        name: 'United States',
        currencyCode: 'usd',
        taxRate: 0,
        countries: ['us'],
      ),
      items: [
        OrderLineItem(
          id: 'item_1',
          variantId: 'var_1',
          productId: 'prod_1',
          productHandle: 'shirt',
          title: 'Shirt',
          unitPrice: const Money(amount: 2000, currencyCode: 'usd'),
          quantity: quantity,
          detail: OrderLineItemDetail(
            deliveredQuantity: quantity,
            returnRequestedQuantity: requestedQuantity,
            returnReceivedQuantity: 0,
            returnDismissedQuantity: 0,
          ),
        ),
      ],
      subtotal: Money(amount: 2000 * quantity, currencyCode: 'usd'),
      shippingTotal: const Money(amount: 0, currencyCode: 'usd'),
      discountTotal: const Money(amount: 0, currencyCode: 'usd'),
      tax: const Money(amount: 0, currencyCode: 'usd'),
      total: Money(amount: 2000 * quantity, currencyCode: 'usd'),
      shippingAddress: returnAddress,
      billingAddress: returnAddress,
      placedAt: returnInstant,
      fulfillmentStatus: OrderFulfillmentStatus.delivered,
      paymentStatus: PaymentStatus.captured,
    );

/// Frozen address used by return fixtures.
const returnAddress = Address(
  firstName: 'Ada',
  lastName: 'Lovelace',
  line1: '12 Analytical Way',
  city: 'Washington',
  postalCode: '20001',
  countryCode: 'us',
);

/// Frozen UTC time used by return fixtures.
final returnInstant = DateTime.utc(2026, 9, 14, 12);
