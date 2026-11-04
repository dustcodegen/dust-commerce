const adminOrderDetailJson = <String, Object?>{
  'id': 'ord_detail',
  'region_id': 'reg_eu',
  'display_id': 1001,
  'email': 'ada@example.com',
  'customer_name': 'Ada Lovelace',
  'currency_code': 'eur',
  'subtotal': 4500,
  'shipping_total': 500,
  'discount_total': 500,
  'tax': 900,
  'total': 5400,
  'status': 'completed',
  'payment_status': 'captured',
  'fulfillment_status': 'not_fulfilled',
  'fulfillments': <Object?>[],
  'shipping_name': 'Standard shipping',
  'shipping_option_id': 'ship_eu_standard',
  'promotion_code': 'WELCOME10',
  'placed_at': '2026-09-10T10:00:00.000Z',
  'created_at': '2026-09-10T10:00:00.000Z',
  'updated_at': '2026-09-10T10:05:00.000Z',
  'payment_provider': 'manual',
  'payment_id': 'pay_detail',
  'payment_amount': 5400,
  'payment_refunded_amount': 0,
  'payment_refunds': <Object?>[],
  'payment_record_status': 'captured',
  'payment_created_at': '2026-09-10T10:01:00.000Z',
  'payment_captured_at': '2026-09-10T10:02:00.000Z',
  'items': <Object?>[
    <String, Object?>{
      'id': 'item_cup',
      'variant_id': 'var_cup',
      'product_id': 'prod_cup',
      'shipping_profile_id': 'sp_default',
      'product_handle': 'espresso-cup',
      'thumbnail': null,
      'title': 'Espresso cup',
      'variant_title': 'Default',
      'unit_amount': 1500,
      'currency_code': 'eur',
      'quantity': 1,
      'created_at': '2026-09-10T10:00:00.000Z',
    },
  ],
  'shipping_address': <String, Object?>{
    'first_name': 'Ada',
    'last_name': 'Lovelace',
    'company': null,
    'line1': '1 Harbour Way',
    'line2': null,
    'city': 'Copenhagen',
    'province': null,
    'postal_code': '1050',
    'country_code': 'dk',
    'phone': '+45 12345678',
  },
  'billing_address': null,
};

const adminFulfillmentJson = <String, Object?>{
  'id': 'ful_01',
  'location_id': 'sloc_main',
  'provider_id': 'manual',
  'shipping_option_id': 'ship_eu_standard',
  'requires_shipping': true,
  'packed_at': null,
  'shipped_at': null,
  'delivered_at': null,
  'canceled_at': null,
  'data': {'service_code': 'ship_eu_standard'},
  'metadata': null,
  'created_by': 'admin_01',
  'marked_shipped_by': null,
  'created_at': '2026-09-14T13:00:00.000Z',
  'updated_at': '2026-09-14T13:00:00.000Z',
  'labels': <Object?>[],
  'items': <Object?>[
    <String, Object?>{
      'id': 'fulitem_01',
      'fulfillment_id': 'ful_01',
      'title': 'Espresso cup',
      'quantity': 1,
      'sku': 'CUP-DEFAULT',
      'barcode': '',
      'line_item_id': 'item_cup',
      'inventory_item_id': null,
      'created_at': '2026-09-14T13:00:00.000Z',
      'updated_at': '2026-09-14T13:00:00.000Z',
    },
  ],
};

final adminFulfilledOrderDetailJson = <String, Object?>{
  ...adminOrderDetailJson,
  'fulfillment_status': 'partially_fulfilled',
  'fulfillments': <Object?>[
    adminFulfillmentJson,
  ],
};

final adminShippedOrderDetailJson = <String, Object?>{
  ...adminOrderDetailJson,
  'fulfillment_status': 'partially_shipped',
  'fulfillments': <Object?>[
    <String, Object?>{
      ...adminFulfillmentJson,
      'shipped_at': '2026-09-14T14:00:00.000Z',
      'marked_shipped_by': 'admin_01',
      'updated_at': '2026-09-14T14:00:00.000Z',
      'labels': <Object?>[
        <String, Object?>{
          'id': 'fullabel_01',
          'fulfillment_id': 'ful_01',
          'tracking_number': 'TRACK-123',
          'tracking_url': 'https://carrier.example/TRACK-123',
          'label_url': '#',
          'created_at': '2026-09-14T14:00:00.000Z',
          'updated_at': '2026-09-14T14:00:00.000Z',
        },
      ],
    },
  ],
};

final adminDeliveredOrderDetailJson = <String, Object?>{
  ...adminOrderDetailJson,
  'fulfillment_status': 'partially_delivered',
  'fulfillments': <Object?>[
    <String, Object?>{
      ...adminFulfillmentJson,
      'delivered_at': '2026-09-14T15:00:00.000Z',
      'updated_at': '2026-09-14T15:00:00.000Z',
    },
  ],
};

final adminCanceledFulfillmentOrderDetailJson = <String, Object?>{
  ...adminOrderDetailJson,
  'fulfillment_status': 'not_fulfilled',
  'fulfillments': <Object?>[
    <String, Object?>{
      ...adminFulfillmentJson,
      'canceled_at': '2026-09-14T16:00:00.000Z',
      'updated_at': '2026-09-14T16:00:00.000Z',
    },
  ],
};
