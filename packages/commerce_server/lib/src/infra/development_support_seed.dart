part of 'development_seed.dart';

/// Support fixtures cover every lifecycle without inventing customer accounts.
const _supportStatements = <_Statement>[
  _Statement(r'''
INSERT INTO customer_service_requests (
  id, name, email, subject, message, order_reference, status,
  resolved_at, created_at, updated_at
)
VALUES
  ('csr_demo_delivery', 'Ada Lovelace', 'ada@example.com',
   'Where is my delivery?',
   'The tracking link has not changed since yesterday.', 'ORDER-1001', 'open',
   NULL, strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-12 minutes'),
   strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-12 minutes')),
  ('csr_demo_size', 'Grace Hopper', 'grace@example.com',
   'Exchange for another size',
   'Could I exchange the medium shirt for a large?', 'ORDER-1002',
   'in_progress', NULL,
   strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-3 hours'),
   strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-45 minutes')),
  ('csr_demo_refund', 'Margaret Hamilton', 'margaret@example.com',
   'Refund received',
   'Thank you, the refund now appears on my statement.', 'ORDER-1003',
   'resolved', strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-1 day'),
   strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-2 days'),
   strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-1 day')),
  ('csr_demo_address', 'Katherine Johnson', 'katherine@example.com',
   'Change delivery address',
   'The order has not shipped. Can you update the delivery address?',
   'ORDER-1004', 'open', NULL,
   strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-5 hours'),
   strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-5 hours')),
  ('csr_demo_stock', 'Dorothy Vaughan', 'dorothy@example.com',
   'Restock notification',
   'Please tell me when the black tee is available in small.', NULL,
   'in_progress', NULL,
   strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-1 day'),
   strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-2 hours'))
ON CONFLICT DO NOTHING
'''),
];
