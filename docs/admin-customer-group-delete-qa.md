# Admin customer-group deletion QA

## Scope

This vertical slice implements Medusa-compatible customer-group deletion in the
admin parity ledger. It includes a
standalone acknowledgement, guarded transactional soft deletion, generated Dio
and Dust state, source-shaped Flutter actions, and live release-browser QA. It
adds no migration or widget test.

The stacked commits are independently reviewable:

- `ca391c8` defines the standalone deletion acknowledgement.
- `52ccbbe` adds the guarded transactional server operation.
- `54dc2b1` adds generated Admin transport and dedicated deletion state.
- `3819b74` adds the functional destructive action and confirmation UI.

## Pinned Medusa comparison

The source target is Medusa commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

`customer-group-general-section.tsx` places Delete below a divider in a
separate destructive action group. Its confirmation uses “Delete Customer
Group”, names the group in the irreversible-action warning, and offers Cancel
and Delete without typed verification. On success it returns to the group list
and reports “Customer group {{name}} was successfully deleted.”

Medusa's Admin `[id]/route.ts` returns an acknowledgement containing `id`,
`object: "customer_group"`, and `deleted: true`. The Dust contract and Flutter
flow retain that boundary and exact English copy.

## Contract and server behavior

`AdminCustomerGroupDeleted` is a standalone response allowlist. It does not
inherit from the detail response or expose metadata, audit ownership, membership
rows, or deletion timestamps.

`DELETE /admin/customer-groups/{id}` runs below the parent Admin route guard and
also extracts `AuthenticatedAdmin`. One SQLx transaction soft-deletes the active
group and all active membership rows. PostgreSQL generates every `deleted_at` and
`updated_at`; no application clock, `ALTER TABLE`, or replacement migration is
introduced. Missing, repeated, and retired targets return `404`, and an injected
membership failure proves the group update rolls back.

The service returns one flat
`Result<Option<AdminCustomerGroupDeleted>, SqlxError>`. A soft-deleted name may
be created again under a new generated id while the old group and memberships
remain historical records.

## Admin behavior

The generated client sends `DELETE` with only the group id. Authorization stays
in the process-owned Dio interceptor. Dedicated deletion state uses `Option` for
the acknowledgement and display-safe failure, prevents duplicate submissions,
and clears transient state between attempts.

The detail menu keeps Edit and Delete in separate visual groups. Delete uses
destructive icon and text treatment, opens the pinned confirmation, and disables
dismissal while submitting. Success returns to a refreshed group list and shows
the exact Medusa message. Every subtree is a widget class rather than a private
method returning `Widget`.

## Live browser and database evidence

API `3878` and a fresh release Admin build on `13002` used the existing
SQLx-history-matching disposable QA database. The synthetic `Delete QA Group`
had one active membership to Ada Lovelace.

Authenticated browser QA verified:

- Edit and Delete are separated by a divider and Delete is destructive;
- the confirmation title, warning, Cancel, and Delete copy match the source;
- Cancel leaves both the group and membership active;
- confirmed deletion returns to the refreshed Customer Groups list;
- the deleted name is absent and the exact success message is visible;
- the group and membership receive database-generated deletion/update times;
- Ada's customer record remains active;
- zero active groups retain the deleted name; and
- a clean healthy-load browser tab has no warning or error logs.

## Validation

- `commerce_admin_shared`: 58 Dust outputs clean; analyzer clean; 31 tests.
- `commerce_server`: 146 normal and 131 database Dust outputs clean; analyzer
  clean; 531 tests.
- `admin_app`: 64 Dust outputs clean; analyzer clean; 148 non-widget tests;
  release Web build succeeded.
- Focused server deletion tests: 4; focused Admin deletion-state tests: 2.
- Every touched handwritten Dart file remains below 180 lines.
- Generated output is rebuilt and validated by Dust in CI.

## Remaining parity boundary

Customer-group Add/remove membership, row selection, detail date filters,
customer address update, and same-state Medusa raster comparison remain separate
slices. The broader Admin and storefront are not yet a complete Medusa
replacement.

final result: passed for source structure and live behavior; same-state raster
comparison remains open.
