# Admin customer address deletion QA

## Scope

This slice implements Medusa-compatible customer-address deletion under issue
[#33](https://github.com/dustcodegen/dust-commerce/issues/33). It does not invent
an address edit screen absent from the pinned Admin source, add customer groups
or RBAC, or add widget tests.

Stacked commits keep each responsibility independently reviewable:

- `8587e29` defines the standalone delete-with-parent Admin response.
- `e04482f` adds the ownership-safe guarded SQLx operation.
- `893a01c` adds generated Dio transport and dedicated Dust state.
- `541aa93` adds the source-shaped action menu and typed confirmation.

## Pinned Medusa comparison

The source target remains Medusa commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

`customer-address-section.tsx` exposes Add plus one delete-only row action. Its
prompt uses `general.areYouSure`, `general.areYouSureDescription` and
`general.typeToConfirm`; the exact address name is both visible context and the
verification value. A missing name displays `n/a` but verifies `address`. The
success toast uses `general.success`, which renders “Success”. Medusa refetches
the customer after the mutation. It does not expose address editing here.

The Flutter row, prompt, fallback behavior, destructive treatment, success copy
and detail refresh follow those source boundaries.

## Backend behavior

`DELETE /admin/customers/{id}/addresses/{address_id}` is protected by the Admin
route guard and also requires `AuthenticatedAdmin` in the handler. One direct
SQLx statement soft-deletes only an active address owned by the active customer;
a foreign customer/address pair, missing record, inactive parent or repeated
request returns `404` without a write. SQLite owns `deleted_at` and the existing
trigger owns `updated_at`.

The exact Medusa-shaped acknowledgement contains `id`, `object`, `deleted` and
the refreshed parent customer. It crosses one flat `Result` boundary and is
serialized directly from the SQLx response projection without an ORM or second
response conversion.

## Admin behavior

The generated Admin client sends the path-scoped `DELETE` request without an
authorization argument; Dio owns bearer attachment. Dedicated Dust state uses
`Option` for the acknowledgement and failure. The detail page disables every
address delete menu during an active command, shows Medusa's success message and
reloads the customer after completion. Every UI subtree is a widget class.

## Live browser evidence

The release Admin build on port `13002` used the SQLx-history-matching disposable
address-creation QA database and the freshly restarted API on `3878`. Browser QA
opened Ada Lovelace's “Head Office” address, found the delete-only ellipsis menu
and rendered the exact pinned warning and verification instruction. “Head
office” kept Delete disabled; exact “Head Office” enabled it. Cancel closed the
prompt and preserved the address.

The final destructive browser click was intentionally not performed. Successful
deletion, parent refresh, repeated-request handling and cross-customer denial are
covered through real server/database integration tests.

## Validation

- `commerce_admin_shared`: 53 Dust outputs clean; analyzer clean; 24 tests.
- `commerce_server`: 138 normal and 124 database Dust outputs clean; analyzer
  clean; 510 tests.
- `admin_app`: 53 Dust outputs clean; analyzer clean; 136 non-widget tests;
  release Web build succeeded.
- Every new handwritten Dart file is at most 125 lines; the touched detail page
  is exactly 180 lines. No generated file was edited by hand.
- Repository gates retain the unchanged baseline of 6 legacy line-count and 22
  legacy backend-structure violations; this slice adds none.

## Remaining parity boundary

Address update remains API-only in Medusa and is not yet implemented here.
Customer groups, group membership, RBAC and same-state Medusa raster comparison
remain under issue #33.
