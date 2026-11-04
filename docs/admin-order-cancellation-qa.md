# Admin whole-order cancellation QA

## Scope

This slice implements Medusa-shaped whole-order cancellation for eligible
orders. It is not a claim of complete Medusa order-management parity.

Pinned source truth:

- Medusa commit `bda24b9725ac697ec5e8f706b503013e20babf12`.
- General section action menu beneath
  `packages/admin/dashboard/src/routes/orders/order-detail/components/`.
- Admin cancellation route beneath
  `packages/medusa/src/api/admin/orders/[id]/cancel/`.

## Production boundary

- `POST /admin/orders/:id/cancel` is protected by the parent Admin route guard
  and requires explicit `AuthenticatedAdmin` extraction.
- The public service boundary is one flat
  `Result<AdminOrderDetailResponse, AdminCancelOrderError>`; SQLx failures are
  translated internally and cannot create `Result<Result<...>>`.
- Direct SQLx `FromRow` projections decode only the explicit Admin response.
- One serialized transaction cancels the order and payment collection, writes
  a refund audit for captured manual payments, restores managed inventory, and
  records the authenticated actor.
- SQLite owns UTC audit timestamps. The Dart clock is not used for table audit
  data.
- Unknown payment providers, active fulfillments, completed orders, missing
  orders, and repeated cancellation are rejected before a partial write.

## Client and interaction

- The generated Dio client sends a bodyless `POST`; its authorization
  interceptor remains the only bearer-token owner.
- The General card uses dedicated action and confirmation widget classes. No
  private method returns a `Widget` for this interaction.
- Source-matched copy is `Are you sure?`, followed by
  `You are about to cancel the order #<display id>. This action cannot be
  undone.` and Cancel/Continue actions.
- A canceled order renders Canceled and Refunded, and its Cancel action is
  disabled.

## Automated verification

- Server suite: 446 tests passed.
- Admin suite: 107 tests passed; no widget tests were added.
- Store suite: 120 tests passed.
- Shared contracts: 151 tests passed.
- Focused server coverage includes authorization, unpaid cancellation, captured
  refund, exact inventory restoration, actor/time audit, invalid lifecycle and
  provider refusal, concurrent retry, and the flat-result compile gate.
- Admin client coverage proves the interceptor supplies authorization, the
  request has no body, and the response decodes as canceled/refunded.
- All five Dust roots reported clean generated output, and analyzers passed.
- SQLx applied all 59 migrations, reverted all 59 to zero application tables,
  and reapplied all 59. The final one-table refund migration is reversible.

## Live localhost evidence

On 2026-09-14, a fresh 59-migration database and deterministic seed were used
with API `3878`, Store `13001`, and Admin `13002`.

1. Store checkout placed order `#1` for one Essential T-Shirt, M / Black. The
   USD 22.00 manual payment was captured while the order remained Pending.
2. Before cancellation, inventory was 19 and refunds were zero.
3. Admin displayed Pending, Captured, and Not fulfilled, then rendered the
   source-matched irreversible confirmation.
4. The localhost API returned `200`; refreshed Admin displayed Canceled and
   Refunded and disabled Cancel.
5. Database verification showed one USD 22.00 refund, payment collection
   Canceled, inventory restored exactly to 20, and `canceled_by` resolved to
   `owner@example.com` with SQLite-generated UTC timestamps.
6. A repeated request returned `422 Order is already canceled`; the refund
   count remained one and inventory remained 20.

The browser verified the confirmation preflight and final refreshed state. The
destructive localhost QA mutation itself was invoked through the local API;
the generated-client submission path is covered by the Admin unit test.

## Remaining order gaps

- Explicit Admin order completion is not implemented.
- Delivered quantities are not yet aggregated into order completion.
- External payment-provider refund adapters remain unavailable by design.
- Customer notification remains disabled until a real notification adapter
  exists.
