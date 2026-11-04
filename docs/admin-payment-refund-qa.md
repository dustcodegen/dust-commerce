# Admin payment refund QA

## Scope

This slice implements Medusa-shaped independent refunds for captured manual
payments. It does not claim support for external payment-provider refunds or a
complete Medusa payment platform.

Pinned source truth:

- Medusa commit `bda24b9725ac697ec5e8f706b503013e20babf12`.
- Refund route and validator beneath
  `packages/medusa/src/api/admin/payments/[id]/refund/` and
  `packages/medusa/src/api/admin/payments/validators.ts`.
- Refund drawer and Payment section beneath
  `packages/admin/dashboard/src/routes/orders/order-detail/components/`.

## Production boundary

- `GET /admin/refund-reasons` and `POST /admin/payments/:id/refund` inherit the
  Admin route guard; the mutation also extracts `AuthenticatedAdmin`.
- The request accepts one positive optional amount plus optional reason and
  note. An omitted amount refunds the complete remaining balance.
- One serialized SQLx transaction validates payment state, reason ownership
  and remaining value before recording the immutable refund audit.
- The public service result is flat. SQLx failures are translated inside the
  feature and cannot form `Result<Result<...>>`.
- Admin responses are direct SQLx `FromRow` allowlists. Provider metadata and
  other internal payment data never enter the contract.
- SQLite generates UTC refund and reason audit timestamps. Integer minor units
  remain the only money representation.
- Manual payments are supported. Unknown or external payment providers return
  `503` before any refund row is written.

## Client and interaction

- The generated Dio client owns authorization and exposes no token parameter.
- The Payment card contains the captured payment, per-payment action, refund
  audit rows and captured total used by the pinned source.
- The right drawer contains amount, optional standardized reason, optional
  note, Cancel and Save. A successful mutation reloads the server-authoritative
  order.
- Partial refunds keep the aggregate payment state Captured and preserve the
  remaining action. A complete refund changes it to Refunded and disables the
  action.
- Every subtree is a widget class; no private helper method returns `Widget`.

## Automated verification

- Server suite: 475 tests passed.
- Admin suite: 112 tests passed; no widget tests were added.
- Admin and server analyzers passed.
- Admin Dust output: 38 scanned and clean.
- Server Dust output: 126 normal and 113 SQLx targets clean.
- A fresh SQLx cycle applied 60 migrations, reverted all 60 to zero application
  tables, and reapplied all 60.
- All seven new or rewritten UI files pass targeted formatting and contain
  41–148 code lines. The repository-wide gates still report five unrelated
  formatting files and six legacy over-limit files.
- Focused server coverage includes authorization, partial and full refunds,
  default remaining amount, invalid reasons, over-refunds, strict bodies,
  provider refusal, concurrency and cancellation after a partial refund.
- Admin coverage verifies Dio authorization, contract decoding and the
  server-authoritative state refresh.

## Live localhost evidence

On 2026-09-14, a new database applied all 60 SQLx migrations. API `3878` and
Admin `13002` used the deterministic development catalogue and a bootstrapped
local merchant.

1. Store APIs placed order `#1` for one Classic White Tee with standard
   shipping, then captured its USD 25.58 manual payment.
2. Desktop Admin displayed the captured payment and opened the refund drawer
   with USD 25.58 refundable plus all four seeded reasons.
3. Admin submitted a USD 10.00 partial refund with reason `Damaged` and note
   `QA partial refund`. The refreshed card kept Captured and rendered its audit.
4. At a 390 by 844 viewport, the payment row, audit row and drawer remained
   usable without horizontal overflow. The drawer offered USD 15.58 remaining.
5. Admin refunded the remainder. The refreshed order displayed Refunded, two
   audits and a disabled Refund action.
6. SQLite contained exactly two refund rows totaling 2558 minor units. The
   first retained its reason and note; the second correctly kept both absent.
7. Browser warning and error logs were empty.

## Remaining gaps

- External provider adapters and reconciliation references are not available.
- Refund-reason merchant CRUD is separate from the seeded reason discovery.
- Same-state raster comparison with a running Medusa Admin remains open.
- Customer notification remains disabled until a real adapter exists.
