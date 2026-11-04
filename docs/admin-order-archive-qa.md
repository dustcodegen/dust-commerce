# Admin order archive QA

## Source boundary

This slice copies Medusa's order-archive capability at pinned commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

Source truth:

- `packages/medusa/src/api/admin/orders/[id]/archive/route.ts`
- `packages/core/core-flows/src/order/workflows/archive-orders.ts`
- `packages/core/core-flows/src/order/steps/archive-orders.ts`
- `packages/modules/order/src/services/order-module-service.ts`
- `www/apps/api-reference/specs/admin/paths/admin_orders_{id}_archive.yaml`

Medusa accepts completed, canceled, or draft orders and changes their status to
`archived`. This project has no draft-order lifecycle, so its exact modeled
allowlist is completed or canceled. Medusa's current Admin dashboard does not
expose an archive control, so Morrow does not invent one.

## Implemented contract

- The original one-shot `orders` migration includes `archived`; no appended
  `ALTER TABLE` migration and no invented `archived_at` column were added.
- Archiving a canceled order preserves `canceled_at` and `canceled_by`.
- SQLite's existing trigger owns the UTC `updated_at` value.
- Store and Admin response contracts decode the typed archived status.
- Archived orders cannot start or capture a payment.
- `POST /admin/orders/:id/archive` is bodyless, protected by the parent Admin
  route guard, and explicitly extracts `AuthenticatedAdmin` in the handler.
- The service exposes one flat
  `Result<AdminOrderDetailResponse, AdminArchiveOrderError>`.
- The lifecycle target and refreshed response are direct SQLx `FromRow`
  projections; no ORM model or duplicate response conversion exists.
- Pending and already-archived orders return 422. Missing orders return 404.

## Generated Admin client

- `AdminOrderDetailApi.archiveOrder` uses the exact bodyless POST path.
- Generated output sends `Object? _data = null`, which Dio transmits as an
  empty body.
- `AdminAuthorizationInterceptor` remains the sole bearer owner; the method has
  no authorization argument.
- No private function or method returning `Widget` was added, and no widget
  test was added.

## Automated verification

- Tests first failed on the absent status, schema constraint, route, and client
  method before their implementations were added.
- Full suites passed: server 460, Store 120, Admin 109, shared contracts 142,
  and Admin contracts 12.
- Dart and Flutter analyzers passed with no issues.
- Dust 0.1.4 normal, database, Admin-client, and i18n checks reported no stale
  errors. The i18n check retains five pre-existing warnings.
- A fresh SQLx reversible up/down/up cycle passed across all migration pairs.
- Seven pre-existing oversized files and five pre-existing formatter drifts
  remain outside this slice.

## Live localhost evidence

On 2026-09-14, a fresh migrated and seeded database served the current stack on
temporary API port `3881`.

1. Store checkout created order `#1` in Pending/Awaiting state.
2. The protected archive route returned 422 while the order was pending.
3. The protected complete route changed the order to Completed.
4. The protected archive route returned 200 with Archived status and database
   UTC `updated_at` value `2026-09-14T02:19:29.894Z`.
5. Repeating archive returned 422 and did not reopen the order.

## Remaining order gaps

- Medusa's archive event has no external event-bus adapter yet.
- Order edits, exchanges, claims, and external payment adapters remain.
