# Admin customer-group date-filter QA

## Scope

This vertical slice closes the Created and Updated filter gap on the protected
customer-group list under issue
[#33](https://github.com/dustcodegen/dust-commerce/issues/33). It reuses the
existing typed server query instead of adding another endpoint or migration.
No widget test or generated-file edit was added.

The stacked commits are independently reviewable:

- `5c86fbd` extracts the shared Medusa-shaped date controls.
- `9aea603` applies them to the customer-group list and extends focused query
  coverage.
- `cfedb65` keeps the Custom picker on the stable root navigator after its
  transient menu closes.

## Pinned Medusa comparison

The source target is Medusa commit
`bda24b9725ac697ec5e8f706b503013e20babf12`.

The pinned customer-group table exposes Created and Updated through Add filter.
Each submenu contains Today, Last 7 days, Last 30 days, Last 90 days, Last 12
months, and Custom. Active filters become editable chips with an independent
clear action, and Add filter lists only inactive fields.

Relevant source:

- `packages/admin/dashboard/src/hooks/table/filters/use-customer-group-table-filters.tsx`
- `packages/admin/dashboard/src/routes/customer-groups/customer-group-list/components/customer-group-list-table/`
- `packages/admin/dashboard/src/components/table/data-table/data-table-filter/date-filter.tsx`
- `packages/admin/dashboard/src/components/data-table/helpers/general/use-data-table-date-filters.tsx`

## Implementation

`AdminDateFilterPreset` owns the five source labels and local-calendar lower
bounds. Custom selection stores an inclusive end-of-day upper bound. Shared
widget classes render the Add-filter submenu and editable active chip; no
private method returns `Widget`.

The group toolbar hides Created or Updated after it becomes active and hides
Add filter when both are active. The existing generated Dio client sends typed
JSON comparisons to the guarded server list. SQL applies both comparisons
before count and paging, and direct SQLx rows retain typed timestamps.

Custom selection captures the root `NavigatorState` before MenuAnchor removes
its overlay. This avoids using a disposed submenu context and keeps the date
route mounted.

## Validation

- Source comparison used the pinned Medusa implementation, not a screenshot
  approximation.
- Live Admin QA signed in through the real API and loaded 13 customer groups.
- Created exposed all five presets plus Custom; selecting Last 7 days created
  an editable chip and left only Updated in Add filter.
- Updated Today produced the correct zero-result state with both active chips.
- Custom opened the range dialog; September 14 through September 14 produced
  the visible custom chip and restored all 13 matching fixture groups.
- Focused Admin preset and ViewModel tests pass; focused server coverage proves
  Created and Updated query behavior through the real route.
- Admin/server analyzers, Admin/server/database Dust checks, file-size,
  structure, formatting, and generated-diff gates pass.

## Remaining parity boundary

A same-state Medusa customer raster comparison remains unavailable. This slice
therefore claims source-structure and live behavior parity, not pixel parity.
Broader Admin and storefront parity is not yet complete.

final result: passed for source structure, typed query behavior, and live
preset/custom interaction.
