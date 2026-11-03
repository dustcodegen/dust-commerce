# Admin customer deletion QA

## Scope

This slice implements Medusa-compatible Admin customer deletion in the admin
parity ledger. It does not add
address mutation, customer groups, RBAC, or widget tests.

Stacked commits keep each responsibility independently reviewable:

- `852fe1a` defines the standalone deletion acknowledgement.
- `0d22aaa` implements the guarded transactional server operation.
- `0b24774` splits the Admin composition root before adding more state.
- `76124ad` adds generated Dio transport and deletion state.
- `7575c08` adds the source-shaped action and confirmation UI.

## Pinned Medusa comparison

The source target remains Medusa commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

- `customer-general-section.tsx` puts Edit and Delete in separate action groups,
  uses destructive Delete treatment, requires the customer email to confirm,
  reports success, and replaces the detail route with `/customers`.
- `useDeleteCustomer` calls the Admin SDK delete operation and invalidates both
  customer list and detail queries.
- `remove-customer-account.ts` soft-deletes the customer, cascades addresses,
  detaches the customer actor from a shared auth identity, and deletes an auth
  identity that has no other actor.

The Flutter action menu, copy and typed confirmation follow those boundaries.
A legacy contactless profile uses its stable id as confirmation because its
email is explicitly absent.

## Backend behavior

`DELETE /admin/customers/{id}` is protected by the Admin route guard and also
extracts `AuthenticatedAdmin` in the handler. One SQLx transaction:

- reads authentication ownership through a direct `FromRow` projection;
- soft-deletes the customer and active reusable addresses with SQLite time;
- preserves carts, orders and immutable order history;
- deletes tokens and verification capabilities for an exclusive identity;
- soft-deletes its provider and auth identities; or
- removes only `customer_id` when another actor owns the same identity.

A registered customer with zero or multiple active identities fails closed and
rolls back. The service returns one flat `Result`; storage errors never become a
nested result or cross the public response boundary.

## Admin behavior

The generated customer client sends `DELETE` without an authorization
parameter; the shared Dio interceptor owns the bearer. Dedicated Dust state
uses `Option<AdminCustomerDeleted>` and a display-safe `Option<String>` failure.
All UI subtrees are widget classes. No widget test was added.

On success the existing Customers navigation reloads page zero, matching
Medusa query invalidation. Repeated, missing and expired-session operations map
to safe state without retaining a stale acknowledgement.

## Live browser evidence

A fresh disposable database applied all 60 current SQLx migrations. API `3878`
and a release Admin build on `13002` used the deterministic development data.
Browser QA created the synthetic guest `delete.qa@example.com`, opened its
detail action menu, and verified:

- Edit and Delete are visually separated;
- Delete uses destructive icon and text treatment;
- the exact Medusa title, warning and typed-confirmation copy are present;
- Delete stays disabled until the exact synthetic email is entered;
- the dialog fits both desktop and `390 x 844`; and
- browser warning and error logs are empty.

The final Delete button was not clicked during browser QA because graphical
data deletion requires action-time confirmation. The real deletion request and
persistence effects are exercised by the non-widget integration suites.

## Validation

- `commerce_admin_shared`: analyzer clean; 21 tests passed; 51 Dust outputs
  clean.
- `commerce_server`: analyzer clean; 501 tests passed; 135 normal and 122
  database Dust outputs clean.
- `admin_app`: analyzer clean; 130 non-widget tests passed; 49 Dust outputs
  clean; release Web build succeeded.
- The new root-only `scripts/verify_package.sh` rejects a package working
  directory and passes the Admin package using the Flutter runner.
- Every touched handwritten Dart file is within 180 lines. Generated output is
  ignored, rebuilt, and validated by Dust in CI.
- Repository-wide gates still report their inherited five formatting, six
  file-size and 22 backend-name structure violations outside this slice.

## Remaining parity boundary

Customer address mutations, customer groups and group membership remain
separate slices. A same-state running Medusa Admin raster was unavailable, so source
and responsive interaction parity are proven here, not pixel identity.
