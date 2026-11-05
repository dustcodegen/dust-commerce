# Admin customer-group membership QA

## Scope

This vertical slice implements Medusa-compatible customer-group membership
changes in the admin parity ledger. It includes one
strict batch contract, an authenticated atomic server operation, generated Dio
and Dust state, a full-screen Add Customers selector, selected-row and per-row
removal, and live release-browser QA. It adds no migration or widget test.

The stacked commits are independently reviewable:

- `f881cbd` defines the standalone add/remove batch.
- `086ed14` adds the guarded transactional server operation.
- `47b1c14` adds generated membership transport and command state.
- `7d9ce13` adds independent candidate-list state.
- `b804c7b` adds the selector and removal UI.

## Pinned Medusa comparison

The source target is Medusa commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

Medusa's `customer-group-add-customers` route uses a full-screen focus form,
10-row customer paging, search, customer filters and ordering. Existing group
members stay checked but disabled with “The customer has already been added to
the group.” New selection is retained across pages and Save requires at least
one customer.

The detail customer section supports page selection, the Remove command, and
Edit/Remove row actions. Removal uses count-aware “Remove customer(s)” copy and
an irreversible-action prompt. Both UI mutations call the same
`POST /admin/customer-groups/{id}/customers` API with `add` or `remove`; the
response refetches the customer group.

## Contract and server behavior

`AdminBatchCustomerGroupCustomers` is a standalone request allowlist with only
`add` and `remove`. It does not inherit from customer or database models.
Unknown fields, empty batches, duplicates, overlapping ids, blank ids, and
batches above 500 customers are rejected.

The route runs below `AdminAuth` and explicitly extracts
`AuthenticatedAdmin`. One SQLx transaction verifies the active group and every
active customer, soft-deletes requested links, inserts only missing links, and
returns the direct customer-group detail projection. Invalid customers cannot
partially remove valid members, and an injected insert failure rolls the whole
batch back.

Existing adds and absent removals are idempotent. PostgreSQL owns membership
creation, update, and deletion timestamps; the authenticated Admin id is stored
as the creation actor. The service returns one flat
`Result<Option<AdminCustomerGroupDetailResult>,
AdminCustomerGroupMembershipFailure>`.

## Admin behavior

The generated client sends the body and group id only; Dio owns Authorization.
Membership and candidate-list ViewModels use dedicated state with `Option` for
the refreshed group and display-safe failure.

Add opens the source-shaped full-screen selector. Existing members are checked
and disabled, page selection excludes them, and new selection survives search,
account filtering, ordering, and paging. Save refreshes detail and shows the
exact singular or plural Medusa success message.

The detail table provides selection, a selected-row Remove command, and per-row
Edit/Remove actions. Removal uses the exact count-aware prompt before the same
batch mutation. Every UI subtree is a widget class; no private method returns a
`Widget`.

## Live browser and database evidence

API `3878` and a release Admin build on `13002` used a disposable 13-group QA
database. Authenticated browser QA opened VIP Customers, added Dorothy Vaughan,
and observed the exact success message and member count change from two to
three. The persisted row contains the authenticated Admin id and equal
database-generated UTC `created_at` and `updated_at` values.

The one-customer Remove action opened the exact singular confirmation and was
canceled so the reusable fixture remained intact. The atomic remove mutation,
idempotency, invalid-target rejection, and rollback behavior are covered by the
server and generated-client integration tests. Browser warning and error logs
were empty after the completed add flow.

## Validation

- `commerce_admin_shared`: 59 Dust outputs clean; analyzer clean; 33 tests.
- `commerce_server`: 147 normal and 132 database Dust outputs clean; analyzer
  clean; 537 tests.
- `admin_app`: 68 Dust outputs clean; analyzer clean; 151 non-widget tests;
  release Web build succeeded.
- Focused membership coverage: 2 contract, 6 server, and 3 Admin state tests.
- All new handwritten Dart remains within the 180-code-line gate.
- Generated output is rebuilt and validated by Dust in CI.

## Remaining parity boundary

Customer address update is now implemented in a later stacked slice.
Customer-group created/updated date filters are now implemented in a later
stacked slice. A same-state Medusa customer raster comparison and broader Admin
and storefront parity remain open.

final result: passed for source structure and live add behavior; removal is
integration-tested and its live confirmation was canceled intentionally.
