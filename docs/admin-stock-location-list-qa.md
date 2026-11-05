# Admin stock-location list QA

## Slice

- Source commit: Medusa `bda24b9725ac697ec5e8f706b503013e20babf12`.
- Source route: Settings > Locations, using Medusa's searchable 20-row list.
- Dust route: authenticated Admin Inventory > Locations.
- Contract: dedicated generated `AdminStockLocationApi`; it does not reuse the
  fulfillment-context client or expose a bearer parameter.

## Boundary

The response is a direct SQLx projection of active stock locations and the
allowlisted address fields needed by the table: id, name, address line, city,
province, postal code and country code. Deleted locations and deleted addresses
are excluded. Create, edit, detail, inventory-item, reservation and
fulfillment-provider actions remain separate slices and are not represented by
fake controls.

## Evidence

- Route-level Admin authentication is inherited from the existing shell guard;
  Dio owns the Authorization header.
- Search, 20-row limit, offset paging, loading, empty and safe failure states
  are implemented in a dedicated ViewModel.
- `dart analyze apps/admin_app` completes with warnings only from existing
  private mixin declarations.
- `dust check --root apps/admin_app` reports `250 clean: 250`.
- `DUST_DATABASE_URL=... dart test packages/commerce_server/test/admin/fulfillment_context_test.dart`
  passes 4 tests, including the address projection.
- Focused Flutter API/ViewModel tests pass 7 tests, including the dedicated
  stock-location contract and server-failure mapping.
- `./scripts/check_structure.sh`, `./scripts/check_file_size.sh`,
  `./scripts/format.sh --check`, and `git diff --check` pass.

No widget tests were added. Pixel comparison and same-state browser capture are
deferred until the route is exercised with a stable seeded Admin session.
