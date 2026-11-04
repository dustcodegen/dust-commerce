# Admin customer-create QA

Validated on 2026-09-14 against Medusa source commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

## Source target

The implementation follows Medusa's customer-create route and
`CreateCustomerForm` rather than reconstructing the screen from a screenshot.
The pinned source defines a full-screen route-focus modal, a 720 px content
column, a one/two-column responsive grid, and this exact field order:

1. optional first name and last name;
2. required email and optional company; and
3. optional phone.

The footer keeps secondary Cancel and primary Create actions visible while the
body scrolls. Success closes the focus route and opens the created customer.

## Implemented slice

- `AdminCreateCustomer` is a standalone five-field Admin input allowlist. It
  contains no password, credentials, sessions or metadata.
- The Admin route guard and explicit `AuthenticatedAdmin` extraction both
  protect `POST /admin/customers`.
- `StrictJsonExtractable` rejects unknown fields before persistence, including
  password-shaped input.
- One SQLx statement inserts an active guest profile and returns the final
  `AdminCustomerDetailResponse` through direct `FromRow` decoding. There is no
  ORM model or second response conversion.
- Duplicate active guest email is a typed conflict. A registered customer may
  retain the same email because Admin creation must not claim or alter account
  ownership.
- SQLite owns both UTC audit timestamps. The command accepts only an id source;
  it has no application clock parameter.
- The generated Admin client serializes the typed body and decodes the explicit
  detail response. Dio remains the only owner of Authorization.
- Dedicated Dust state prevents duplicate submission and retains only an
  `Option<AdminCustomerDetail>` or display-safe failure.
- Flutter composition uses dedicated widget classes; no widget test was added.

## Live browser evidence

The current API ran on `3878` against the existing disposable QA database and a
fresh release Admin build ran on `13002`. Browser QA created the synthetic guest
`dorothy.qa@example.com` with name, company and phone through the real form.

The app then opened the new customer detail directly. The General section
showed Dorothy Vaughan, NACA, the supplied phone, and Guest status; Addresses
and Orders correctly rendered empty states. Returning to Customers refreshed
the server list from five to six rows.

At the default 1280 px viewport the form used the source's two-column layout.
At `390 x 844` it collapsed to one column while retaining the sticky footer and
all five inputs. Browser warning and error logs were empty after creation and
responsive QA.

This proves source structure and live behavior. A same-state raster from a
running Medusa Admin was not available, so pixel parity is not claimed.

## Full validation

- `commerce_admin_shared`: analyzer clean; 19 tests passed.
- `commerce_server`: analyzer clean; 491 tests passed.
- `admin_app`: analyzer clean; 124 non-widget tests passed.
- Dust checks: 132 server, 119 database projections and 45 Admin-app outputs
  clean with zero stale outputs.
- Every touched handwritten file remains within 180 lines. Generated output is
  ignored, rebuilt, and validated by Dust in CI.
- Changed-slice scans found no private widget-building method and no nested
  `Result` signature.
- Repository-wide format and file-size gates still report inherited files
  outside this slice; none was rewritten or mixed into these commits.

## Remaining parity boundary

Customer edit and deletion are now covered by their dedicated QA documents.
Address mutations and customer groups remain separate vertical slices in this
ledger. Customer creation intentionally makes a non-authenticating guest
profile; Store account registration remains the only password-bearing customer
flow. Those capability boundaries stay visible here rather than being implied
complete by an external tracker.
