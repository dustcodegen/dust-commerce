# Admin customer-group list QA

## Scope

This slice implements Medusa-compatible customer-group discovery in the admin
parity ledger. It does not add
group creation, detail, edit, deletion, membership mutation, address update or
widget tests. Unsupported actions are absent instead of appearing functional.

Stacked commits keep each responsibility independently reviewable:

- `1e0e245` defines the standalone Admin list response and query allowlist.
- `20968aa` adds the final schemas and protected direct SQLx list operation.
- `9d7a5c6` adds the generated Dio client and dedicated Dust list state.
- `bf2fa5e` adds the functional responsive Admin route and navigation.

## Pinned Medusa comparison

The source target remains Medusa commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

`customer-group-list-table.tsx` defines a 10-row table, `q`, `order`, `offset`,
`created_at` and `updated_at` queries, and the response fields
`id,name,created_at,updated_at,customers.id`. It renders Name, Customers,
Created, Updated and an action column. `en.json` supplies “Customer Groups”,
“No customer groups”, “There are no customer groups to display.”, “No results”
and “No customer groups match the current filter criteria.” The shared date
formatter is called with `includeTime: true`, so time is visible in each row.

The Flutter list implements those read controls and exact empty-state strings.
It intentionally withholds the source Create action, row link and edit/delete
menu until their protected backend slices exist.

## Backend behavior

`GET /admin/customer-groups` is protected by the Admin route guard and also
requires `AuthenticatedAdmin` in the handler. Search, creation/update date
comparisons and six order values are parsed through explicit allowlists before
count and 10-row paging. The direct SQLx response nests only active customer
ids; inactive groups, customers and memberships are excluded.

The unreleased final schema uses one reversible migration for
`customer_groups` and one for `customer_group_customers`, without an appended
`ALTER TABLE`. Inline comments explain identity, ownership, metadata,
membership history and timestamp behavior. PostgreSQL generates UTC `TIMESTAMPTZ`
UTC timestamps and maintains `updated_at`; active membership uniqueness still
allows a customer to be re-added after a soft deletion.

## Admin behavior

The generated customer-group client has no authorization parameter; Dio owns
bearer attachment. Dedicated Dust state retains query, date filters, ordering,
count and page bounds, uses `Option` for display-safe failure, and ignores stale
responses. The route uses widget classes for every UI subtree and no widget
test was added.

## Live browser evidence

A fresh disposable database applied all 62 SQLx migrations. API `3878` and a
fresh release Admin build on `13002` used 12 deterministic groups and four
customers with membership counts from zero to three.

Authenticated browser QA verified:

- responsive sidebar and drawer navigation opens Customer Groups;
- the first page shows 10 of 12 results and Next opens rows 11–12;
- searching `VIP` returns only VIP Customers with its count of two;
- an unmatched query renders the exact filtered empty-state copy;
- Name A-to-Z ordering is applied by the server before paging;
- the Created date-range picker produces a removable active filter;
- compact rendering uses horizontal table scrolling without overflow;
- `1440 x 900` renders all four source columns and paging controls; and
- after source review, Created/Updated headers and visible local times match
  the component's locale and formatter calls.

## Validation

- `commerce_admin_shared`: 54 Dust outputs clean; analyzer clean; 26 tests.
- `commerce_server`: 140 normal and 126 database Dust outputs clean; analyzer
  clean; 516 tests.
- `admin_app`: 56 Dust outputs clean; analyzer clean; 139 non-widget tests;
  release Web build succeeded.
- SQLx CLI 0.8.6 applied all 62 migrations, reverted to zero application
  tables, then applied all 62 again.
- Every touched handwritten Dart file remains within 180 code lines. The
  repository-wide size gate still reports the same six legacy violations.
- Generated output is rebuilt and validated by Dust in CI.

## Remaining parity boundary

Customer-group creation is the next vertical slice. Detail, edit, deletion,
membership mutation, address update and a same-state Medusa Admin raster
comparison remain separate tracked slices.
