# Admin order completion QA

## Source boundary

This slice copies Medusa's explicit order-completion API at pinned commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

Source truth:

- `packages/medusa/src/api/admin/orders/[id]/complete/route.ts`
- `packages/core/core-flows/src/order/workflows/complete-orders.ts`
- `packages/core/core-flows/src/order/steps/complete-orders.ts`
- `packages/modules/order/src/services/order-module-service.ts`
- `www/apps/api-reference/specs/admin/paths/admin_orders_{id}_complete.yaml`

Medusa changes only the order status to `completed`. It rejects canceled orders
but does not require captured payment, fulfillment, shipment, or delivery. Its
current dashboard General action menu exposes cancellation only, so Morrow does
not invent a completion button.

## Implemented contract

- `POST /admin/orders/:id/complete` is mounted beneath the parent Admin route
  guard and explicitly extracts `AuthenticatedAdmin` in the handler.
- The request is bodyless and returns the existing explicit Admin order-detail
  response.
- The public service boundary is one flat
  `Result<AdminOrderDetailResponse, AdminCompleteOrderError>`.
- A direct SQLx `FromRow` target reads only the lifecycle status needed for the
  decision.
- Pending and already-completed orders become or remain Completed. Missing
  orders return 404 and canceled orders return 422.
- The serialized SQLx transaction updates only `orders.status`, then reads the
  refreshed direct SQLx response.
- No migration or `completed_at` column was added because Medusa's order model
  has neither. SQLite's existing trigger owns the UTC `updated_at` mutation.
- Payment and fulfillment remain independent facts and are never fabricated by
  completion.

## Generated Admin client

- `AdminOrderDetailApi.completeOrder` uses the exact bodyless POST path.
- Generated output sends `_data = null`.
- Dio's `AdminAuthorizationInterceptor` remains the only bearer owner; the API
  method has no authorization parameter.
- The dashboard intentionally does not call the method because the pinned
  Medusa Admin UI exposes no equivalent control.

## Automated verification

- Server focused tests first failed on the absent route, then all five passed.
- Focused coverage proves the route guard, pending completion with awaiting
  payment and partial fulfillment, already-completed retry, canceled refusal,
  missing refusal, and the compile-time flat Result boundary.
- Full server suite: 451 tests passed.
- Admin client test first failed on the absent generated method, then passed.
- Full Admin suite: 108 tests passed; no widget tests were added.
- `dart analyze` and `flutter analyze --no-pub` passed.
- Dust 0.1.4 generated the SQLx row/DAO and HTTP client outputs. Server normal
  and database checks and Admin normal checks reported zero stale outputs.

## Live localhost evidence

On 2026-09-14, the current API ran on `3878` against the existing fresh
59-migration QA database. Store `13001` and Admin `13002` used that API.

1. Store placed order `#2` for one Essential T-Shirt, M / Black, with a USD
   22.00 captured manual payment.
2. Before completion, the database reported Pending and Captured with no
   fulfillment.
3. The protected completion route returned 200 and the explicit response
   reported Completed, Captured, and Not fulfilled.
4. Refreshed Admin detail displayed those same three badges and the existing
   order summary, customer, payment, and activity facts.
5. Repeating completion returned 200 and kept the order Completed.
6. Applying completion to canceled order `#1` returned 422 and left its
   Canceled/Refunded lifecycle unchanged.

## Remaining order gaps

- The completion event has no external event-bus adapter yet.
- Archive and order-edit workflows remain unimplemented.
- External payment and notification adapters remain unavailable by design.
