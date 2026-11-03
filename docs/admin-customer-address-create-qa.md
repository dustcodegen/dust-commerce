# Admin customer address creation QA

## Scope

This slice implements Medusa-compatible address creation in the admin parity
ledger. It does not add
address update/delete, customer groups, RBAC, or widget tests.

Stacked commits keep each responsibility independently reviewable:

- `08025f4` defines the standalone Admin input and explicit response fields.
- `04aab13` adds the guarded transactional server operation and final table.
- `1db2c72` adds generated Dio transport and dedicated Dust state.
- `1676fd9` shares the complete country catalogue across Admin forms.
- `64f0cd6` adds the source-shaped focus form and customer-detail refresh.
- `809c181` prevents the verifier from formatting deleted rename paths.

## Pinned Medusa comparison

The source target remains Medusa commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

`create-customer-address-form.tsx` defines the full-screen Route Focus form,
720 px content boundary, two-column desktop fields, required address name,
address line 1 and country, optional secondary fields, and Cancel/Save footer.
The `customers.addresses.create.header` and `.hint` locale keys render “Create
Address” and “Create a new address for the customer.” The customer address
section owns the Add action and labels saved rows by address name.

The Flutter form follows those source boundaries and uses the shared complete
ISO country catalogue. Compact layout intentionally collapses to one column;
the desktop-only alignment spacer is not emitted below the breakpoint.

## Backend behavior

`POST /admin/customers/{id}/addresses` is protected by the Admin route guard and
also requires `AuthenticatedAdmin` in the handler. A strict wire allowlist
rejects undeclared fields. One transaction verifies the active parent, inserts
the address, applies default flags atomically and returns the refreshed direct
SQLx customer allowlist through one flat `Result` boundary.

The unreleased `customer_addresses` migration is its one-shot final table: no
appended `ALTER TABLE` migration exists. SQLite owns ISO-8601 UTC `created_at`
and `updated_at`, nullable source fields remain nullable SQL data, and the
reversible down file drops the table cleanly.

## Admin behavior

The generated Admin client posts the typed input without an authorization
parameter; Dio owns bearer attachment. Dedicated Dust state represents the
created customer and failure with `Option`. The full-screen UI is composed from
widget classes and private `part` implementations; no widget-returning helper
method or widget test was added.

## Live browser evidence

A fresh disposable database applied all 60 SQLx migrations. API `3878` and a
release Admin build on `13002` used three deterministic customer fixtures.
Authenticated browser QA opened Ada Lovelace, submitted every form field for
“Head Office”, returned to the refreshed detail page and displayed the saved
address. A direct database read confirmed the country code, optional fields,
phone and database-generated UTC timestamps. Empty submission exposed the
three required validations.

The final build rendered the exact pinned locale heading and hint. Desktop and
`390 x 844` captures verified the sticky footer, scrollable focus surface and
one-column compact form without a blank alignment row.

## Validation

- `commerce_admin_shared`: 52 Dust outputs clean; analyzer clean; 23 tests.
- `commerce_server`: 136 normal and 123 database Dust outputs clean; analyzer
  clean; 506 tests.
- `admin_app`: 51 Dust outputs clean; analyzer clean; 134 non-widget tests;
  release Web build succeeded.
- SQLx CLI 0.8.6 ran all 60 migrations, reverted to zero application tables and
  ran all migrations again.
- Every touched handwritten Dart file remains within 180 code lines. Generated
  output is ignored, rebuilt, and validated by Dust in CI.

## Remaining parity boundary

Address update/delete, customer groups, group membership, and a same-state
running Medusa Admin raster comparison remain separate tracked slices.
