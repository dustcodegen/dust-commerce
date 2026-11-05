# Admin customer-group edit QA

## Scope

This vertical slice implements Medusa-compatible customer-group editing in the
admin parity ledger. It includes a
standalone Admin input, guarded server mutation, generated Dio and Dust command
state, source-shaped Flutter drawer and live release-browser QA. It adds no
schema migration or widget test.

The stacked commits are independently reviewable:

- `40f4406` defines the validated customer-group edit input.
- `8d6d637` adds the guarded transactional update operation.
- `abb05d0` adds the generated Admin client and dedicated edit state.
- `10f8a5b` adds the functional action menu and edit drawer.

## Pinned Medusa comparison

The source target is Medusa commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

`customer-group-general-section.tsx` places Edit in the first action group and
Delete in a separate destructive group. `customer-group-edit.tsx` opens a
`RouteDrawer` titled “Edit Customer Group”.
`edit-customer-group-form.tsx` initializes the existing name, validates one
required Name field, submits the update and exposes Cancel/Save footer actions.
The server `[id]/route.ts` uses authenticated `POST` and returns the refreshed
`customer_group` envelope.

The Flutter detail exposes only Edit because deletion is not implemented yet;
it does not render a disabled or fake destructive action. The 560 px right-side
drawer follows the source title, field order and sticky actions.

## Contract and server behavior

`AdminUpdateCustomerGroup` is a standalone Admin request, not a create-input or
database-model subtype. Its generated SerDe boundary trims the required
1–255-character name. Metadata is intentionally absent because Medusa's edit
drawer sends only the name; metadata remains a separate detail-section concern.

`POST /admin/customer-groups/{id}` runs below the parent Admin route guard and
also extracts `AuthenticatedAdmin`. Strict JSON extraction accepts only `name`.
One transaction updates the active row, lets PostgreSQL generate `updated_at`, then
uses the existing SQLx `FromRow` detail response directly. The service returns
one flat `Result<Option<...>, SqlxError>`; missing and soft-deleted groups share
`404`.

The update preserves id, customers, metadata and `created_at`. This slice uses
the existing final `customer_groups` table and trigger: no application clock,
`ALTER TABLE`, replacement migration or ORM layer was introduced.

## Admin behavior

The generated client accepts only id and typed body. Authorization remains in
the process-owned Dio configuration. Dedicated edit state uses `Option` for the
updated detail and display-safe failure, and prevents duplicate submissions
while saving.

The detail action menu opens the source-shaped drawer. Name is prefilled and
autofocused; empty input is rejected locally; Escape, Close and Cancel dismiss
only while idle; Save returns the direct typed detail, refreshes the route and
shows “Customer group {{name}} was successfully updated.” Every subtree is a
widget class rather than a private method returning `Widget`.

## Live browser evidence

API `3878` and a fresh release Admin build on `13002` used the existing
SQLx-history-matching disposable database with 13 customer groups.

Authenticated browser QA verified:

- the General action menu contains the functional Edit action;
- the drawer preloads `VIP Customers` and shows the exact source title, Name,
  Cancel and Save copy;
- Escape dismisses the drawer without mutation;
- blank submission renders “Name is required” without closing;
- saving `VIP Members` refreshes the breadcrumb and General title;
- saving `  VIP Customers  ` restores the normalized canonical fixture;
- the exact success message is visible after save;
- PostgreSQL retains `created_at` and advances its generated `updated_at`;
- compact and `1440 x 1000` layouts keep the drawer usable; and
- the final browser warning/error log is empty.

## Validation

- `commerce_admin_shared`: 57 Dust outputs clean; analyzer clean; 31 tests.
- `commerce_server`: 145 normal and 130 database Dust outputs clean; analyzer
  clean; 527 tests.
- `admin_app`: 62 Dust outputs clean; analyzer clean; 146 tests; release Web
  build succeeded.
- Focused server route tests: 4; focused Admin edit-state tests: 2.
- Every touched handwritten Dart file remains below 180 lines; the largest new
  UI file is 173 lines.
- Generated output is rebuilt and validated by Dust in CI.
- The repository-wide naming linter still reports 22 historical filenames
  outside this slice; every new backend operation uses the permitted `update`
  name and introduces no new naming debt.

## Remaining parity boundary

Customer-group deletion, Add/remove membership, row selection, detail date
filters and same-state Medusa raster comparison remain separate slices. The
broader Admin and storefront are not yet a complete Medusa replacement.

final result: passed for source structure and live behavior; same-state raster
comparison remains open.
