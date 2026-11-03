# Admin customer-edit QA

Validated on 2026-09-14 against Medusa source commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

## Source target

The implementation follows Medusa's `customer-edit` route and
`EditCustomerForm` source. The pinned source defines a right-side route drawer,
email-first one-column fields, a disabled registered-account email with an
explanation, and sticky Cancel and Save actions. It sends no email mutation for
a registered account and sends `null` when another contact field is cleared.

The General card exposes Edit through its action menu. Delete remains absent
because deactivation/deletion is a separate server capability rather than a
disabled or simulated action in this slice.

## Implemented slice

- `AdminUpdateCustomer` is an explicit five-field Admin command. It contains no
  password, credential, session or metadata field.
- The parent route guard and explicit `AuthenticatedAdmin` extraction protect
  `PATCH /admin/customers/{id}`. `StrictJsonExtractable` rejects unknown keys,
  including password-shaped input, before any write.
- One transaction reads the current explicit detail, applies a guarded direct
  SQLx replacement, and returns the final `AdminCustomerDetailResponse` through
  the same direct `FromRow` projection. The service exposes one flat typed
  result rather than `Result<Result<...>>`.
- Guest email is required and conflicts only with another active guest.
  Registered-account email ownership is immutable; omitted email retains the
  stored value. Other nullable fields may be cleared.
- SQLite owns `updated_at`; neither the contract nor service accepts a clock.
- The generated Admin client accepts a typed body and no token. Dio remains the
  sole Authorization owner.
- Dedicated Dust edit state retains an `Option<AdminCustomerDetail>` or one
  display-safe failure. The edit drawer refreshes the detail route after save.
- Flutter subtrees are dedicated widget classes. No widget test was added.

## Live browser evidence

The API ran on `3878` against the disposable QA database and a fresh release
Admin build ran on `13002`. Browser QA opened Dorothy Vaughan from Customers,
used General's action menu, changed the company from `NACA` to
`NACA Research Center`, saved through the real PATCH route, and observed the
refreshed value on the detail card.

Ada Lovelace's registered profile opened the same source-shaped drawer with the
email visibly disabled and the other fields editable. At `390 x 844` the drawer
filled the compact viewport while retaining every field and the sticky footer.
Browser warning and error logs were empty.

This proves source structure and live behavior. A same-state raster from a
running Medusa Admin was not available, so pixel parity is not claimed.

## Full validation

- `commerce_admin_shared`: analyzer clean; 20 contract tests passed.
- `commerce_server`: analyzer clean; 496 tests passed.
- `admin_app`: analyzer clean; 127 non-widget tests passed; release Web build
  succeeded.
- Dust checks: 50 Admin-contract, 133 server, 120 database and 47 Admin-app
  outputs clean with zero stale files.
- Every touched handwritten file is within 180 lines; `main.dart` is exactly
  180 lines. Generated output is rebuilt and validated by Dust in CI.
- Changed-slice review found no widget-building helper method, response
  inheritance, intermediate response model or nested `Result` signature.
- Repository-wide format and file-size gates still report only their inherited
  five-file and six-file baselines outside this slice.

## Remaining parity boundary

Customer deletion is now covered by `admin-customer-delete-qa.md`. Address
mutations, customer groups and group membership remain separate vertical slices
in the admin parity ledger. Registered email changes remain an account-ownership operation
and are intentionally rejected by this profile editor.
