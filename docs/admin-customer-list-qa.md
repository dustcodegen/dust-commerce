# Admin customer-list QA

Validated on 2026-09-14 against Medusa source commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

## Source target

The implemented shape comes from Medusa's customer list route, table columns,
filters and query hook:

- `customer-list-table.tsx`
- `use-customer-table-columns.tsx`
- `use-customer-table-filters.tsx`
- `use-customer-table-query.tsx`

The pinned source uses a protected 20-row table with Email, Name, Account and
Created columns; text search; registered/guest and created/updated filters; and
allowlisted ordering by email, first name, last name, account, creation time or
update time.

## Implemented slice

- `GET /admin/customers` is protected by the parent route guard and explicitly
  extracts `AuthenticatedAdmin` in its handler.
- The direct SQLx `FromRow` response selects only id, email, first name, last
  name, account state and database-owned timestamps.
- Store and Admin contracts remain separate. The response is a standalone
  allowlist and does not inherit a database or domain model.
- The generated Dio method contains no authorization argument; the existing
  Admin interceptor remains the bearer owner.
- Flutter state uses `Option` for absent account and failure values. Search,
  account/date filters, ordering and stable server paging survive refreshes.
- Every UI subtree is a widget class. No widget test was added.

Customer creation and detail are now covered by their own QA slices. Mutation
and groups remain separate responsibilities in the admin parity ledger.

## Guest acquisition correction

The first real guest checkout completed but created no customer-list row. The
checkout boundary was corrected before QA continued:

- `placeOrder` now exposes one `Result<OrderResponse, CheckoutError>` instead
  of a nested result, while retaining the original SQLx cause internally.
- Guest checkout atomically upserts one active `has_account = 0` profile per
  email from the shipping contact.
- PostgreSQL generates `created_at` and maintains `updated_at`; checkout supplies
  neither timestamp.
- Guest orders intentionally retain `customer_id = NULL`, preserving the
  existing secure order-transfer flow until a registered customer claims them.

## Live browser evidence

The current stack ran on Store `13001`, Admin `13002` and API `3878` against a
disposable SQLx database. Four registered profiles were created through
`POST /store/customers`. A complete guest journey then created a cart, line,
standard delivery method and manual payment session before
`POST /store/checkout` returned `201`.

The Admin customer screen rendered all five profiles. Browser QA verified:

- `Ada` search returned only Ada Lovelace;
- Registered filtering retained the four account profiles;
- Guest filtering returned only Katherine Johnson;
- Email ascending ordering placed Ada first;
- desktop and `390 x 844` layouts retained every control and a horizontally
  scrollable table;
- the active filter chip and Clear all action restored the full list; and
- browser warnings and errors were empty after the final guest path.

The protected query and generated client are covered by focused server and
Flutter tests. Checkout and order-transfer regression suites prove guest
persistence without weakening order ownership or transfer behavior.

## Full validation

- `commerce_admin_shared`: analyzer clean; 17 tests passed.
- `commerce_server`: analyzer clean; 482 tests passed.
- `admin_app`: Flutter analyzer clean; 117 non-widget tests passed.
- Dust generation checks passed for the normal 128-query and database
  115-query modes.

## Remaining parity boundary

This proves source-structure and live behavior parity for the implemented list.
It does not prove same-state pixel parity with a running Medusa Admin. Customer
creation, detail, edit and deletion now have dedicated QA documents; groups and
live pagination beyond 20 rows remain separate vertical slices.
