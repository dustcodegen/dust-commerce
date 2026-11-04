import 'support.dart';

/// Inserts one complete frozen order snapshot for Admin detail tests.
Future<void> seedOrderDetail(AdminHarness harness) async {
  await harness.raw(r'''
INSERT INTO customers (id, email, first_name, last_name, phone, has_account)
VALUES ('cus_ada', 'ada@example.com', 'Ada', 'Lovelace', '+45 12345678', 1)
''');
  await harness.raw(r'''
INSERT INTO carts (id, region_id, customer_id, email, completed_at)
VALUES ('cart_detail', 'reg_eu', 'cus_ada', 'ada@example.com',
        '2026-09-10T10:00:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO orders
  (id, display_id, cart_id, region_id, customer_id, email, currency_code,
   subtotal, shipping_total, discount_total, tax, total, status,
   payment_status, shipping_option_id, shipping_name, promotion_code,
   placed_at, created_at, updated_at)
VALUES
  ('ord_detail', 1001, 'cart_detail', 'reg_eu', 'cus_ada',
   'ada@example.com', 'eur', 4500, 500, 500, 900, 5400, 'completed',
   'captured', 'so_standard', 'Standard shipping', 'WELCOME10',
   '2026-09-10T10:00:00.000Z', '2026-09-10T10:00:00.000Z',
   '2026-09-10T10:05:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO order_items
  (id, order_id, variant_id, product_id, product_handle, thumbnail, title,
   variant_title, unit_amount, currency_code, quantity, created_at)
VALUES
  ('item_cup', 'ord_detail', 'var_cup', 'prod_tshirt', 'espresso-cup',
   'https://images.example/cup.jpg', 'Espresso cup', 'Default',
   1500, 'eur', 1, '2026-09-10T10:00:00.000Z'),
  ('item_shirt', 'ord_detail', 'var_shirt_m', 'prod_sweatshirt', 't-shirt',
   NULL, 'T-shirt', 'M / Black', 1500, 'eur', 2,
   '2026-09-10T10:00:01.000Z')
''');
  await harness.raw(r'''
INSERT INTO order_addresses
  (order_id, kind, first_name, last_name, company, line1, line2, city,
   province, postal_code, country_code, phone)
VALUES
  ('ord_detail', 'shipping', 'Ada', 'Lovelace', NULL, '1 Harbour Way',
   NULL, 'Copenhagen', NULL, '1050', 'dk', '+45 12345678'),
  ('ord_detail', 'billing', 'Ada', 'Lovelace', 'Analytical Engines',
   '2 Logic Lane', 'Suite 7', 'London', 'Greater London', 'SW1A 1AA',
   'gb', NULL)
''');
  await harness.raw(r'''
INSERT INTO payment_collections
  (id, order_id, provider, amount, currency_code, status, created_at,
   captured_at)
VALUES ('pay_detail', 'ord_detail', 'manual', 5400, 'eur', 'captured',
        '2026-09-10T10:01:00.000Z', '2026-09-10T10:02:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO fulfillments
  (id, order_id, location_id, provider_id, shipping_option_id,
   requires_shipping, created_by, data, created_at, updated_at)
VALUES
  ('ful_detail', 'ord_detail', 'sloc_main', 'manual', 'ship_eu_standard',
   1, 'admin_1', '{"service_code":"ship_eu_standard"}',
   '2026-09-10T10:03:00.000Z', '2026-09-10T10:03:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO fulfillment_items
  (id, fulfillment_id, title, quantity, sku, barcode, line_item_id,
   created_at, updated_at)
VALUES
  ('fulitem_detail', 'ful_detail', 'Espresso cup', 1, 'CUP-DEFAULT', '',
   'item_cup', '2026-09-10T10:03:00.000Z',
   '2026-09-10T10:03:00.000Z')
''');
  await harness.raw(r'''
INSERT INTO fulfillment_labels (
  id, fulfillment_id, tracking_number, tracking_url, label_url,
  created_at, updated_at
) VALUES (
  'fullabel_detail', 'ful_detail', 'TRACK-123',
  'https://carrier.example/TRACK-123', '#',
  '2026-09-10T10:04:00.000Z', '2026-09-10T10:04:00.000Z'
)
''');
}
