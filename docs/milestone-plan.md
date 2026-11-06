# Commerce milestones

This plan follows one release epic at a time. Each epic is locally verified,
reviewed as a stacked commit series, and merged only after the CI rate-limit
window allows one remote cycle.

## Epic 1 — storefront/admin parity stack

[PR #55](https://github.com/dustcodegen/dust-commerce/pull/55) is open. The
first two Verify runs found file-size and handler-naming regressions. The
checkout contract tests now have their own file, and the cart form handler
lives under `handler/create/`. Both frozen checks pass locally.

Delivery also needs the deployed API origin in the GitHub repository variable
`PRODUCTION_API_BASE_URL`. The merge starts a fresh Verify run on `main`, and
Delivery packages that revision after Verify succeeds.

Release evidence:

- Server Dust generation, analyzer, and 609 tests pass locally.
- Store Dust generation, analyzer, and 179 tests pass locally.
- Browser smoke proves the Medusa-compatible atomic form add-to-cart path.
- No widget tests were added.

## Epic 2 — verified customer email change

Use the Medusa profile editor layout and add real email verification. The
[Medusa reference](https://github.com/medusajs/dtc-starter/blob/4a1d53dc434ed124a78c4e2c9f312e1f47d4e9eb/apps/storefront/src/modules/account/components/profile-email/index.tsx)
has a placeholder submit action.

- Require the current password on the authenticated request. Keep the existing
  login active while a dedicated, expiring capability is pending. Send the link
  to the normalized new address and require an explicit confirmation action.
- Atomically consume the capability, update the customer and provider email,
  and revoke sessions. Coordinate with sign-in and password rotation. Preserve
  the customer ID and existing order snapshots.
- Prove expiry, replay, supersession, duplicate-email races, delivery failure,
  retry, and concurrent sign-in in local API tests. Verify the confirmation
  and sign-in flow in desktop and compact browsers using test SMTP.

## Epic 3 — external payment/refund providers

Add provider adapters behind the existing payment/refund contracts, with
idempotency, provider failure mapping, and receipt-safe responses. Keep manual
payment behavior as the deterministic local provider.

## Epic 4 — remaining Medusa admin inventory parity

Complete stock-location detail, inventory-item and reservation views, location
mutations, and the matching Admin browser evidence without sharing Admin API
contracts with the Store package.

## Release rule

Before publishing an epic, run its package gates and the repository format,
file-size, structure, and generated-output checks locally. Check the latest CI
start time before pushing or merging. Leave at least one hour between CI starts,
including the run started by the merge. After the epic passes Verify and merges,
fast-forward local `main` and start the next milestone from a fresh branch.
