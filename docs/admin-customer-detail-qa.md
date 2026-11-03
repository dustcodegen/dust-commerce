# Admin customer-detail QA

Validated on 2026-09-14 against Medusa source commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

## Source target

The implemented shape comes from Medusa's customer detail route and its
General, Addresses and Orders sections:

- `customer-detail/customer-detail.tsx`;
- `components/customer-general-section/`;
- `components/customer-address-section/`; and
- `components/customer-order-section/`.

The pinned route uses its two-column layout at the `xl` viewport breakpoint.
General and Orders occupy the main column; Addresses occupies the 440 px side
column with a 16 px gap. The layout collapses to one column below that point.

## Implemented slice

- `GET /admin/customers/{id}` is protected by the parent Admin route guard and
  explicitly extracts `AuthenticatedAdmin` in the handler.
- One direct SQLx `FromRow` projection reads only merchant-visible customer
  fields. Ordered active addresses are aggregated in that projection and
  decoded into standalone response allowlists.
- Credentials, sessions, metadata and deletion fields never enter the response.
  Missing and soft-deleted customers share the same `404` boundary.
- The existing `GET /admin/orders` accepts a validated `customer_id`; both rows
  and count are constrained before paging.
- Generated Dio clients have no authorization argument. The Admin interceptor
  remains the only bearer owner.
- Customer profile and order-section state have separate lifecycles and use
  `Option` for absence. The Orders section keeps search, all allowlisted sorts
  and 10-row server paging.
- Flutter composition uses dedicated widget classes. No widget test was added.

The source's Edit action now opens the functional customer editor documented in
`admin-customer-edit-qa.md`. Delete is omitted and address-add remains visible
but disabled because their backend mutations do not exist yet. Customer groups
are not rendered for the same reason.

## Store-to-Admin evidence

The current API ran on `3878` against the disposable QA database. The existing
Store account `ada.qa@example.com` authenticated successfully. Through the real
Store API it then:

1. created a default shipping and billing address in Copenhagen;
2. created an EU cart and added `var_demo_01`;
3. selected `ship_eu_standard` and a manual payment session; and
4. completed authenticated checkout as order `#4`.

Because checkout was authenticated, the order retained Ada's customer id. The
Admin detail subsequently returned the same address and only Ada's order.

## Live browser evidence

The release Admin build ran on `13002` against the same API. Browser QA verified:

- the customer-list row opens Ada's dedicated detail state;
- General renders the registered account, name and explicit missing values;
- Addresses renders the Store-created address and both default roles;
- Orders renders order `#4`, its channel, payment, fulfillment and EUR total;
- opening `#4` renders the full order detail, and its in-app return action
  restores Ada's customer detail rather than the global order list;
- the default 1280-wide browser uses Medusa's main plus 440 px side grid;
- `390 x 844` collapses the sections and retains the horizontally scrollable
  order table; and
- browser warning and error logs are empty on the final build.

This is source-structure and live-behavior evidence. No equivalent live Medusa
customer fixture was available, so same-state pixel parity is not claimed.

## Full validation

- `commerce_admin_shared`: analyzer clean; 18 tests passed.
- `commerce_server`: analyzer clean; 486 tests passed.
- `admin_app`: Flutter analyzer clean; 121 non-widget tests passed.
- Dust checks: 48 Admin-contract, 131 server, 43 Admin-app and 118 database
  projections clean with zero stale outputs.
- The largest touched handwritten UI file remains 165 lines; generated output
  is ignored, rebuilt, and validated by Dust in CI.
- Changed-slice scans found no private widget-building method and no nested
  `Result`; repo-wide legacy findings remain tracked separately.

## Remaining parity boundary

Customer creation, edit and deletion are now covered by their dedicated QA
documents. Address mutations, groups and a same-state Medusa raster remain
separate vertical slices. Issue #33 therefore remains open; this slice completes
only read-only detail, addresses and customer-owned order history.
