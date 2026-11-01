# Admin customer-address update QA

## Scope

This vertical slice implements Medusa-compatible partial customer-address
updates under issue
[#33](https://github.com/dustcodegen/dust-commerce/issues/33). It adds a standalone
tri-state request contract, an authenticated atomic server operation, and a
generated Dio client. It adds no migration, visible Edit control, ViewModel, or
widget test.

The stacked commits are independently reviewable:

- `c3ea1ca` defines the standalone partial-update contract.
- `45c0962` adds the guarded transactional server operation.
- `8db3d9c` adds generated Admin transport and client-to-server coverage.

## Pinned Medusa comparison

The source target is Medusa commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

Medusa defines `POST /admin/customers/{id}/addresses/{address_id}` and routes it
through `updateCustomerAddressesWorkflow`. Its Admin SDK hook sends a partial
address body and then invalidates customer-address queries. The pinned customer
address section exposes Add and Delete actions but no Edit action. This slice
therefore implements the real contract without adding unsupported UI.

Relevant source:

- `packages/medusa/src/api/admin/customers/[id]/addresses/[address_id]/route.ts`
- `packages/medusa/src/api/admin/customers/validators.ts`
- `packages/admin/dashboard/src/hooks/api/customers.tsx`
- `packages/admin/dashboard/src/routes/customers/customer-detail/components/customer-address-section/`

## Contract and server behavior

`AdminUpdateCustomerAddress` is a standalone public allowlist. Every text field
uses `Option<String?>`: `None` preserves the stored value, `Some(value)` replaces
it, and `Some(null)` explicitly clears an optional value. Required street and
country fields cannot be cleared. Boolean defaults use `Option<bool>`. Unknown,
empty, incorrectly typed, and oversized requests are rejected before storage.

The route sits below `AdminAuth` and explicitly extracts
`AuthenticatedAdmin`. Its repository updates only an active address owned by
the supplied active customer. SQLite JSON presence checks preserve the
omitted-versus-null distinction without an ORM or a second model conversion.

One SQLx transaction applies the patch and refetches the direct customer-detail
allowlist. SQLite owns default-address uniqueness and automatic UTC
`updated_at`; the application passes no clock value. Missing, deleted,
foreign-parent, and inactive-parent addresses return the same not-found
boundary without disclosing ownership. Storage failure rolls back both field
and default changes. The service exposes one flat
`Result<Option<AdminCustomerDetailResponse>, SqlxError>`.

## Admin transport

The generated method accepts only customer id, address id, and the standalone
body. Authorization is attached by Dio and is not a method parameter. Dust
serializes only present fields, retaining explicit JSON nulls, and decodes the
refreshed standalone customer response.

Because the pinned dashboard has no address Edit action, no UI or ViewModel was
created. A real generated-client-to-server integration test verifies the POST
method, Dio-level bearer handling, explicit nullable clearing, omitted-field
preservation, and typed response decoding.

## Validation

- Shared contract: Dust clean, analyzer clean, 2 focused tests.
- Server: Dust and database generation clean, analyzer clean, 6 focused update
  tests and 15 combined address create/update/delete tests.
- Admin: Dust clean, analyzer clean, generated-client integration test passed.
- File-size, backend-structure, response-inheritance, nested-Result, private
  Widget-builder, formatting, and generated-diff gates passed.
- Generated output is rebuilt and validated by Dust in CI.

## Remaining parity boundary

Customer-group created/updated date controls are now implemented in a later
stacked slice. A same-state Medusa customer raster comparison remains. Address
update has no visual comparison because the pinned Medusa Admin presents no
corresponding screen or action. Broader parity is not yet complete.

final result: passed for the pinned API contract and generated client behavior.
