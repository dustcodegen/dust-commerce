# Admin customer-group creation QA

## Scope

This vertical slice implements Medusa-compatible customer-group creation in the
admin parity ledger. It adds the
standalone Admin request and response contracts, guarded server operation,
generated Dio command state, source-matched focus form and live browser QA.

When this slice was QA'd, customer-group detail, edit, deletion and membership
mutation remained separate slices. The successful form therefore returned to
and refreshed the functional list instead of navigating to a fabricated detail
route. No widget test was added.

Follow-on commit `5c3420f` implements the real detail route. Current successful
creation now navigates through that tested route; the evidence below records
the original creation slice before detail existed.

The stacked commits are independently reviewable:

- `a5dc7a1` defines the validated creation input.
- `2700983` defines the explicit Medusa response envelope.
- `3576ffe` adds the guarded direct SQLx creation operation.
- `d39afb7` adds the generated Dio method and Dust command state.
- `627b8c9` extracts shared route-focus form chrome.
- `5c4ef63` makes the visible Escape affordance functional.
- `9498e0e` adds the responsive creation form and list action.

## Pinned Medusa comparison

The comparison target is Medusa commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

`customer-group-list-table.tsx` exposes a Create action leading to
`/customer-groups/create`. `create-customer-group-form.tsx` defines a route
focus modal with a required Name field, 720 px maximum content width, 72 px
body-top padding, a two-column grid, and Cancel/Create footer actions. The form
submits `POST /admin/customer-groups`, shows the localized success toast and
navigates to the created group detail.

`en.json` supplies the exact visible copy:

- “Create Customer Group”
- “Create a new customer group to segment your customers.”
- “Customer group {{name}} was successfully created.”

The Flutter form matches the available source behavior and copy. Navigation to
detail is the only intentional boundary because that route does not exist yet.

## Contract and server behavior

`AdminCreateCustomerGroup` trims the required 1–255 character name through its
Dust SerDe codec. Optional metadata uses a nullable wire backing with an
`Option` accessor and is not exposed by the form. The separate create response
contains only the allowlisted customer-group contract.

`POST /admin/customer-groups` is protected by the parent Admin route guard and
also extracts `AuthenticatedAdmin` in the handler. Strict JSON extraction
rejects undeclared fields. One flat `Result` crosses the service boundary; the
direct SQLx insert returns the response projection without an intermediate
model conversion.

The existing final `customer_groups` table generates both timestamps. Creation
records the authenticated Admin in `created_by`, persists optional metadata and
returns an empty customer membership list. This slice adds no migration,
`ALTER TABLE`, application timestamp or password-shaped field.

## Admin behavior

The generated API method accepts only the typed body. Authorization remains in
the process-owned Dio interceptor. Dedicated Dust state uses `Option` for the
created group and display-safe failure, rejects duplicate submissions while
saving, and maps validation and expired sessions without retaining stale data.

The route-focus UI uses widget classes rather than widget-returning helper
methods. Its Name field becomes full width below the desktop grid breakpoint.
Close, Cancel and Escape dismiss the form only while no submission is active.
Successful creation refreshes the real server list and shows the exact Medusa
success text.

## Live browser evidence

API `3878` and a fresh release Admin build on `13002` used the existing
SQLx-history-matching disposable database with all 62 migrations, 12 groups and
four customers.

Authenticated browser QA verified:

- the source Create action opens the full-screen focus form;
- exact header and hint copy, Name label, Cancel and Create are visible;
- empty submission renders “Name is required” without a request;
- submitting `  Regional Partners  ` stores and displays `Regional Partners`;
- the refreshed newest-first list increases from 12 to 13 groups;
- the new group reports zero customers and the exact success message;
- SQLite stores non-null `created_by`, null metadata and matching generated
  `created_at`/`updated_at` instants;
- the default compact layout remains usable;
- `1440 x 1000` renders the 720 px source body and half-width Name field; and
- Escape closes the fresh release form and returns to the list.

## Validation

- `commerce_admin_shared`: 55 Dust outputs clean; analyzer clean; 28 tests.
- `commerce_server`: 142 normal and 127 database Dust outputs clean; analyzer
  clean; 519 tests.
- `admin_app`: 58 Dust outputs clean; analyzer clean; 141 tests; release Web
  build succeeded.
- Every touched handwritten Dart file remains within 180 code lines; the
  largest customer-group creation UI file is 120 lines.
- Generated output is rebuilt and validated by Dust in CI.

## Remaining parity boundary

Customer-group detail is next because Medusa creation routes directly to it.
Edit, deletion, membership add/remove, customer-address update and same-state
Medusa raster comparison remain separate tracked slices.
