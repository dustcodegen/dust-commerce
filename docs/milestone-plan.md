# Commerce milestones

This plan follows one release epic at a time. Each epic is locally verified,
reviewed as a stacked commit series, and merged only after the CI rate-limit
window allows one remote cycle.

## Epic 1 — storefront/admin parity stack

Status: PR #55 is open. Local validation is green; the first remote run exposed
two frozen-debt baselines, both corrected locally. The latest baseline fix is
`9d41e3fa` and is waiting for the one-hour CI window before push.

Release evidence:

- Server Dust generation, analyzer, and 609 tests pass locally.
- Store Dust generation, analyzer, and 179 tests pass locally.
- Browser smoke proves the Medusa-compatible atomic form add-to-cart path.
- No widget tests were added.

## Epic 2 — verified customer email change

Build a separate pending-email capability with current-password confirmation,
single-use hashed token delivery, atomic provider/customer email replacement,
session revocation, and a standalone Flutter profile editor. Do not reuse the
registration verification row for a different lifecycle.

## Epic 3 — external payment/refund providers

Add provider adapters behind the existing payment/refund contracts, with
idempotency, provider failure mapping, and receipt-safe responses. Keep manual
payment behavior as the deterministic local provider.

## Epic 4 — remaining Medusa admin inventory parity

Complete stock-location detail, inventory-item and reservation views, location
mutations, and the matching Admin browser evidence without sharing Admin API
contracts with the Store package.

## Release rule

Never start another CI run within one hour of the previous run. After one epic
passes local and remote validation, merge that epic, pull `main`, and begin the
next milestone from a fresh feature branch.
