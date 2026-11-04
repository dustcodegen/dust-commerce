# Customer service vertical slice

Validated on 2026-09-15 as a Morrow extension to the pinned Medusa sources.
This is not presented as a Medusa API-parity claim.

## Source boundary

- DTC source: `medusajs/dtc-starter` at
  `19e8a6fbefea5a385e9502409908bfbebbecf526`.
- Admin source: `medusajs/medusa` at
  `bda24b9725ac697ec5e8f706b503013e20babf12`.
- The pinned DTC tree has no customer-service or contact route. Its footer
  contains catalogue and Medusa project links only.
- The pinned Medusa Admin tree has no customer-service inbox module. Dust uses
  the existing Medusa shell, table, filter, status-badge and dialog language
  for a product-specific extension instead of inventing a separate UI system.

The 2026-09-15 drift check found the DTC `main` branch two commits ahead of its
pin, limited to dependency and generated build metadata changes. Medusa
`develop` was 52 commits ahead of its Admin pin; changed Admin/API areas include
search, promotions and product queries, not a customer-service module.

## Delivered stack

Each responsibility is an independent local commit and branch:

1. `c35cf32` — final one-table customer-service contract and reversible SQLx
   migration.
2. `b9f5dc7` — guest-compatible Store submission API.
3. `67de61a` — guarded Admin list and lifecycle API.
4. `551c183` — Store form, public routes and order-reference handoff.
5. `97f6b3f` — Admin inbox, filters, detail and lifecycle controls.
6. `91e1be1` — five idempotent development inbox fixtures.
7. `2cf8a64` — singular and plural request-count copy.

Nothing in this stack is pushed, opened as a pull request, merged, deployed or
proven live outside the local development environment.

## Production boundaries

- Store and Admin contracts remain in separate packages.
- Store submission is public with optional authenticated customer ownership.
- Admin list and mutation routes require the route-level Admin bearer guard and
  authenticated extractor.
- Dio owns Flutter authorization; generated methods accept no bearer parameter.
- Direct SQLx `FromRow` projections return explicit allowlists. Response DTOs do
  not inherit database or domain models.
- Absence is surfaced as `Option`; status is a typed enum; audit values decode
  as UTC `DateTime`.
- SQLite owns request creation, update and resolution timestamps. The final
  one-shot table has no appended `ALTER TABLE` migration.
- ViewModels expose one success/failure boundary and never return nested
  `Result<Result<...>>` values.
- Generated `.g.dart` output remains ignored and is rebuilt by CI.

## Automated evidence

- Admin focused support tests: 7 passed.
- Full Admin suite: 162 passed; `flutter analyze --no-pub` found no issues.
- Full server suite after demo seeding: 553 passed.
- Dust Admin check: 71 of 71 clean.
- Dust server check: 152 of 152 clean.
- Handwritten formatting, 180-line budget and structure/result-boundary gates
  passed.
- No customer-service widget test was added.

## Rendered browser evidence

A fresh SQLx-owned QA database was migrated without modifying the older local
database. The Admin app ran on `13002` against the API on `3878` and proved:

- Argon2id-backed Admin sign-in succeeds.
- Five seeded requests render across Open, In progress and Resolved.
- Request detail exposes the complete customer message and optional account and
  order references.
- Open filtering returns the one matching row after a lifecycle change.
- Searching `refund` returns the resolved refund request.
- Changing a request from Open to In progress persists and refreshes the row.
- Singular count copy visibly renders `1 request`.
- The footer attribution remains `Powered by dust`.

## Remaining support scope

The slice is a usable intake and triage inbox. Production support operations
still need separately designed ownership/RBAC, internal notes, merchant replies,
attachments, notification delivery, SLA/audit reporting and retention policy.
Those are workflow extensions, not Medusa DTC parity blockers, and must remain
separate future responsibilities.
