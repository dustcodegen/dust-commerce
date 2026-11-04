# Admin design QA

## Source truth

- Pinned Medusa source commit:
  `bda24b9725ac697ec5e8f706b503013e20babf12`.
- Shell source:
  `packages/admin/dashboard/src/components/layout/main-layout/main-layout.tsx`
  and `shell/shell.tsx`.
- Product source:
  `packages/admin/dashboard/src/routes/products/product-list/product-list.tsx`
  and `components/product-list-table/product-list-table.tsx`.
- Order-list source:
  `packages/admin/dashboard/src/routes/orders/order-list/components/order-list-table/order-list-table.tsx`
  plus `hooks/table/columns/use-order-table-columns.tsx` and
  `hooks/table/filters/use-order-table-filters.tsx` at the pinned commit.
- Order-detail source:
  `packages/admin/dashboard/src/routes/orders/order-detail/order-detail.tsx`
  plus its General, Summary, Payment, Fulfillment, Customer and Activity
  section components at the pinned commit.
- Order-shipment source:
  `packages/admin/dashboard/src/routes/orders/order-detail/components/order-fulfillment-section/order-fulfillment-section.tsx`,
  `packages/admin/dashboard/src/routes/orders/order-create-shipment/`, and
  `packages/medusa/src/api/admin/orders/[id]/fulfillments/[fulfillment_id]/shipments/route.ts`
  at the pinned commit.
- Order-fulfillment-cancellation source:
  `packages/admin/dashboard/src/routes/orders/order-detail/components/order-fulfillment-section/order-fulfillment-section.tsx`
  and
  `packages/medusa/src/api/admin/orders/[id]/fulfillments/[fulfillment_id]/cancel/route.ts`
  at the pinned commit.
- Order-export source:
  `packages/admin/dashboard/src/routes/orders/order-export/order-export.tsx`,
  `components/export-filters.tsx`, the order API export hook and
  `packages/medusa/src/api/admin/orders/export/route.ts` at the pinned commit.
- Order-region-filter source:
  `hooks/table/filters/use-order-table-filters.tsx`,
  `hooks/table/query/use-order-table-query.tsx`, `hooks/api/regions.tsx`, and
  `packages/medusa/src/api/admin/regions/route.ts` at the pinned commit.
- Product-query source:
  `hooks/table/query/use-product-table-query.tsx`,
  `hooks/table/filters/use-product-table-filters.tsx`, and the shared
  DataTable filter and order-by components at the pinned commit.
- Product-list sales-channel source:
  `components/table/table-cells/product/sales-channels-cell/sales-channels-cell.tsx`
  and the product table adapter at the pinned commit.
- Product-detail source:
  `packages/admin/dashboard/src/routes/products/product-detail/product-detail.tsx`
  plus its General, Media, Options, Variants, Sales Channels, Shipping,
  Organization and Attributes section components.
- Product shipping-profile source:
  `packages/admin/dashboard/src/routes/products/product-detail/components/product-shipping-profile-section/`
  and `packages/admin/dashboard/src/routes/products/product-shipping-profile/`
  at the pinned commit.
- Shipping-profile settings source:
  `packages/admin/dashboard/src/routes/shipping-profiles/` at the pinned commit,
  plus Medusa's official Shipping Profiles list, create and detail screenshots.
- Product-delete source:
  `components/product-list-table/product-list-table-actions.tsx`, the detail
  `product-general-section.tsx`, `hooks/api/products.tsx`, and the English
  product deletion translations at the pinned commit.
- Product-edit source:
  `packages/admin/dashboard/src/routes/products/product-edit/product-edit.tsx`,
  `components/edit-product-form/edit-product-form.tsx`, and
  `packages/admin/dashboard/src/components/common/switch-box/switch-box.tsx`.
- Product-create source:
  `packages/admin/dashboard/src/routes/products/product-create/product-create.tsx`
  and the Details, Organize and Variants form components beneath it.
- Product-export source:
  `packages/admin/dashboard/src/routes/products/product-export/product-export.tsx`
  and `components/export-filters.tsx` at the pinned commit.
- Product-media source:
  `packages/admin/dashboard/src/routes/products/product-media/` and the
  product-detail `product-media-section.tsx` at the pinned commit.
- Image-variant source:
  `packages/admin/dashboard/src/routes/products/product-image-variants-edit/`
  plus the image command bar in `product-media-section.tsx` at the pinned
  commit.
- Variant-edit source:
  `packages/admin/dashboard/src/routes/product-variants/product-variant-edit/`
  and its `product-edit-variant-form.tsx` at the pinned commit.
- Variant-pricing source:
  `packages/admin/dashboard/src/routes/products/product-prices/pricing-edit.tsx`,
  `packages/admin/dashboard/src/routes/products/common/variant-pricing-form.tsx`
  and the shared DataGrid currency cell at the pinned commit.
- Product-option source:
  `packages/admin/dashboard/src/routes/products/product-detail/components/product-option-section/`
  and `packages/admin/dashboard/src/routes/product-options/product-option-edit/`
  at the pinned commit.
- Global product-option source:
  `packages/admin/dashboard/src/routes/product-options/product-option-list/`,
  `product-option-detail/`, and `product-option-create/` at the pinned commit.
- Customer-detail source:
  `packages/admin/dashboard/src/routes/customers/customer-detail/customer-detail.tsx`
  plus its General, Addresses and Orders section components and the shared
  two-column layout at the pinned commit.
- Customer-group edit source:
  `packages/admin/dashboard/src/routes/customer-groups/customer-group-detail/components/customer-group-general-section/customer-group-general-section.tsx`,
  `customer-group-edit/customer-group-edit.tsx`, its edit form, and
  `packages/medusa/src/api/admin/customer-groups/[id]/route.ts` at the pinned
  commit.
- Rendered reference: Medusa's official Admin product-list image in the User
  Guide, official product-detail image in the Edit Product guide, and official
  Details-step image in the Create Product guide.
- Prototype: the authenticated Morrow Admin at port `13002`, backed by the
  local API on a temporary database.

## Compared state

The list renders use the light product-list state with Products selected, four
or more published products, no active filters, and the first page. The detail
renders use a published sweatpants product with two images, one Size option,
inventory variants, collection, category, tags and weight.

The official product-detail source and the running prototype were emitted
together at a `1280 x 720` browser surface. The reference raster is itself
letterboxed and scaled inside that surface, so this establishes structural,
spacing, hierarchy and responsive fidelity rather than pixel identity.

The general-edit comparison uses the pinned RouteDrawer implementation as
source truth: right-side drawer, Medusa field order, lifecycle selector,
discountable switch box, and sticky Cancel/Save footer.

The customer-group edit pass uses the pinned RouteDrawer and one-field form as
source truth. The running Admin was exercised at its compact viewport and at
`1440 x 1000`; no equivalent same-state Medusa raster was available, so this
proves source structure and live behavior rather than pixel parity.

The product-create comparison puts the official Medusa Details-step reference
and the running Morrow form into one `2560 x 720` image. Both sides use a
`1280 x 720` viewport and the same empty Details state. This is a direct
head-to-head inspection, not two separately judged screenshots.

The media follow-up uses the same official raster and running implementation in
the in-app browser at `505 x 583`. The source remains letterboxed, so this pass
verifies hierarchy, field order, upload proportions and compact behavior rather
than pixel identity.

The post-create detail-card pair uses Medusa's official `1516 x 853` media
section raster and Morrow's running product detail, each captured in a
`1280 x 720` in-app browser surface and combined into one `2560 x 720` image.
The current pinned source selects Medusa's two-column layout; the older guide
raster crops that surrounding layout, so card tokens and content are directly
comparable while page-column width is not. The editor implementation was
captured at `1280 x 720`, but no same-state Medusa editor raster is available.

The image-variant drawer was exercised at `505 x 583`: one selected image opens
the right-side surface with its 80px preview, search, tri-state selection,
Title/SKU/Thumbnail columns and Cancel/Save footer. Medusa publishes no
same-state association-drawer raster, so source structure and browser behavior
are verified but pixel comparison remains blocked.

The variant-detail comparison uses live Medusa `2.20.1` and Morrow drawers in
the in-app browser at equal `1280 x 720` viewports. The two captures were
combined into one `2560 x 720` image before judging the implementation.

The product-option comparison uses the same live source, browser, viewport and
combined-image method. Both drawers use dark theme and four values. Their value
orders differ because each isolated database supplies a different persisted
rank; the layout and ordering behavior are directly comparable.

The global product-option list and Size detail use live Medusa `2.20.1` and
Morrow in light theme. The `1291 x 772` Medusa captures were center-cropped to
the same `1280 x 720` content surface as Morrow, then each pair was combined
into one `2560 x 720` image. Merchant fixtures and value rank differ; shell,
cards, tables, searches, status labels, result counts and pagination are
directly comparable.

The global product-option create comparison uses the same normalized live
source/build method and the same empty form state. Both render the full-screen
focus surface, 720px content column, title and value fields, close/esc chrome,
and sticky Cancel/Save footer in one `2560 x 720` comparison.

The variant-pricing pass uses the pinned source code as structural truth and
the running Morrow screen at `1280 x 720`. The local Medusa process continued
serving its Admin route, but its existing in-app-browser tab stopped responding
to capture, so this pass does not claim same-state pixel parity.

The product-stock pass uses Medusa's pinned `product-stock` route, form, schema
and DataGrid columns as structural truth. Morrow keeps the full-screen header,
variant title/SKU rows and sticky Cancel/Save footer, but maps the location
columns to its real aggregate inventory model instead of showing fake stock
locations. The Morrow screen and end-to-end mutation were captured live; the
local Medusa tab again timed out, so pixel parity is not claimed.

The product shipping-profile card uses Medusa's official Shipping configuration
raster plus the pinned detail section as source truth. An equal `1280 x 720`
comparison corrected the heading, inset component surface, spacing and label
weight. The drawer now follows the pinned title and clearable searchable
combobox instead of exposing its choices permanently. Live QA narrowed the
server results, selected and cleared the optional relationship, restored
Fragile Goods, and saved with no browser warnings or errors. No same-state
Medusa drawer raster is available, so drawer pixel parity remains unproven.

The Shipping Profiles settings slice now follows Medusa's list, focus create,
detail and typed deletion source. Live QA searched and paged the protected list,
created Bulky Goods, opened its direct response, deleted it after typing the
exact name, returned to the refreshed list, and followed Default Shipping
Profile from the product card into Settings. A second clean-start pass applied
the Type filter, observed only Fragile Goods, changed the server order and
cleared the filters with no browser errors. The official list screenshot
confirms heading, copy, Add filter, search, ordering, two-column table, row
actions, paging density and card geometry. Name, type and date filters plus all
eight orders are real API operations; a same-state combined source capture is
still unavailable, so whole-screen pixel parity is not claimed.

The product-delete pass uses the pinned list and detail action-group source as
structural truth. Morrow exposes Edit followed by a separately divided Delete
action and uses Medusa's exact confirmation and success/error text. The local
Medusa tab again timed out during capture, so this pass verifies source
structure and live behavior without claiming same-state pixel parity.

The product-query comparison uses live Medusa and Morrow product lists in the
in-app Browser at equal `1280 x 720` viewports, light theme, four published
products and the filter menu open. Both neutral and menu states were combined
into `2560 x 720` images before judging. The filter order and labels available
in that earlier slice match source; Sales Channel filtering remains a separate
query-control slice.

The product-list sales-channel pass uses Medusa's official `1280 x 720`
product-list image and the running Morrow list at the same capture size. The
neutral and three-channel focused states were each combined into `2560 x 720`
images. This directly verifies the source's empty, one/two-name and first-two
plus `+N more` rules. It does not establish whole-screen pixel parity: Morrow's
220px shell and 48px rows are roomier than the reference, and unavailable seed
thumbnails render as placeholders.

The order-list pass uses the pinned Medusa source as structural truth and the
running Morrow screen at desktop `1440 x 900` plus the app's narrow default
viewport. Six local demo orders exercise multiple customers, currencies,
countries and payment states. No same-state Medusa order raster is available,
so this pass does not claim pixel parity.

The order-detail pass uses the same pinned source and a complete local order at
desktop `1440 x 900` plus the app's narrow default viewport. Two frozen line
items, captured payment, shipping/billing addresses and distinct activity
timestamps exercise every implemented section. No same-state Medusa order
detail raster is available, so this pass proves source hierarchy, responsive
behavior and real-data rendering without claiming pixel parity.

The order-export pass uses the pinned drawer and filter-summary source plus the
running Morrow Admin at desktop `1440 x 900` and the app's narrow default
viewport. The live table was narrowed to Ada before opening the drawer, so the
visible `Search · Ada` and `Order · Created newest` chips prove the export uses
the current query. No same-state Medusa raster is available; source structure,
responsive behavior and the real CSV download are verified without claiming
pixel parity.

The order-region pass uses Medusa's separate region discovery hook and
searchable multi-select definition as source truth. The running Morrow Admin
was exercised at desktop `1440 x 900` and the app's narrow default viewport;
Europe reduced six demo orders to the three real EUR-region rows and the export
drawer rendered the same merchant-facing region name. No same-state Medusa
raster is available, so pixel parity is not claimed.

## Verified

- The 220px navigation hierarchy, selected row, nested product links, merchant
  identity and bottom utilities follow the pinned shell source.
- The 48px top bar, 12px main gutter, neutral bordered container, title/actions
  header, filter/search/order toolbar, dense table and server-owned pagination
  follow the product-list source.
- Sign-in, session restoration, product loading, title-or-handle search,
  pagination, responsive drawer, notifications, theme selection and sign-out
  are wired. Controls whose backend operation is not implemented report that
  they require the next Admin API slice.
- Remote merchant thumbnails use Flutter's HTML image strategy on web because
  Medusa's public seed CDN omits CORS headers.
- Clicking a real product opens its authenticated detail. General, ordered
  media, options, variants, organization and attributes are API-backed; the
  two-column desktop layout collapses into one column below 900px.
- The General-section action opens an API-backed edit drawer. Real update,
  optional-value clearing, all four lifecycle transitions, automatic detail and
  list refresh, validation, and duplicate-handle conflict states were exercised
  against the temporary local database.
- Create opens the source-shaped full-screen focus surface with progress tabs,
  General fields, automatic handle, variant enablement, option/value setup,
  Organize attributes, regional price and inventory controls, and draft/publish
  actions. A two-variant product was published in the browser, opened in admin
  detail, and then rendered by handle in the storefront with its USD price.
- Creation failures are atomic: duplicate handle, duplicate SKU, incomplete
  option selection and incomplete active-currency pricing are covered by server
  integration tests. The generated admin client is exercised by non-widget
  view-model tests.
- Details now includes the source-positioned Media section. Real files use the
  generated multipart client, server byte limits and signature detection; rows
  can be reordered, removed or made thumbnail. Publication verifies each staged
  file, stores ordered image rows atomically, exposes them through the separate
  storefront contract, and blocks staged deletion after attachment.
- Existing-product media now opens a source-shaped focus surface. Upload,
  four-column drag ordering, selection, deletion, thumbnail promotion, Cancel
  cleanup and Save are wired to one authenticated generated-client operation.
  A browser pass reordered two real images, changed the thumbnail, saved, and
  confirmed compact ranks plus the new thumbnail in SQLite. Browser logs had no
  errors.
- Selecting one media item exposes Delete and Manage associated variants. The
  drawer persists add/remove deltas through the guarded generated client,
  refreshes detail state, and reopens with the saved checkbox state. Cross-
  product, overlapping and stale-image mutations are rejected atomically, and
  deleting media removes its stale associations.
- Clicking a variant row opens the supported right-side editor. Its generated
  client reaches a route-level guarded API for title, material, SKU, EAN, UPC,
  barcode, physical/customs attributes, ordered option selections, inventory
  policy and backorder policy. The 560px inset drawer, sticky chrome, exact
  hints, compact switches and searchable 250-country selector match the live
  Medusa drawer. Server integration tests cover authorization, ownership,
  conflicts, database-owned timestamps and storefront readback; non-widget
  view-model tests cover refreshed state and display-safe failures. Browser QA
  saved Denmark, observed success, reopened the drawer and confirmed readback.
- Clicking a product option opens the 560px inset editor for its title, chips
  and persisted rank. The generated Admin client reaches a route-level guarded,
  transactional API that rejects wrong ownership, duplicate titles, invalid
  values and removal of values used by active variants. Browser QA renamed the
  option, added a value, confirmed the refreshed Admin detail and storefront
  readback, then restored the canonical fixture. Non-widget Admin tests include
  distinct display-safe messages for both 409 cases.
- The Products sub-navigation now exposes Medusa's global Options list. The
  generated authenticated client loads, searches, paginates, creates and opens
  safe option detail responses; detail search filters real values and products,
  and edits refresh both routes. The source-shaped action menus also delete
  unused options through a route-guarded soft-delete transaction and return a
  display-safe conflict while an active product still uses the option. Browser
  QA searched values and products, created and deleted a temporary Material
  option, rejected deletion of linked Size, edited Size, restored the canonical
  fixture and observed no application error. Twenty-one non-widget Admin and
  258 server tests pass; no widget tests were added.
- Each variant action now opens Medusa's full-screen pricing focus surface with
  a read-only title column, active-currency columns and sticky Cancel/Save
  controls. A route-level guarded generated client replaces the complete price
  graph transactionally and returns the refreshed direct SQLx response.
  Currency fields use ISO 4217 precision and exact integer conversion rather
  than assuming two decimals or using floating point. Browser QA changed EUR
  and USD, observed the new USD value immediately on the storefront, then
  restored both canonical values. Twenty-six non-widget Admin and 265 server
  tests pass; no widget tests were added.
- Variants now expose Medusa's product-level Edit stock action. The full-screen
  grid saves every shown variant through one route-guarded generated-client
  request, with editable aggregate quantity and inventory management policy.
  Browser QA changed a real variant to 7 unmanaged units, confirmed the
  separate Store response immediately returned that state, then restored 20
  managed units. Empty, duplicate, negative and cross-product selections are
  rejected before partial writes. Twenty-eight non-widget Admin and 269 server
  tests pass; no widget tests were added.
- Product list rows and the detail General card now expose one shared
  source-shaped Edit/Delete action menu. Browser QA deleted a temporary
  published product through the confirmation, observed the row disappear and
  independently received Store `404`. SQLite retained the product, variant and
  two price rows with generated deletion timestamps. Global options remain
  active, while product-exclusive options are retired transactionally. Thirty
  non-widget Admin and 273 server tests pass; no widget tests were added.
- The generated Admin client and ViewModel now carry server-owned status,
  ordering and pagination together. Focused HTTP tests cover multiple status
  values, all six supported sort values, filtering before paging, stable
  counts, and `400` responses for unknown values. Live API QA returned exact
  ascending and descending title order and rejected `order=handle`. Thirty-two
  non-widget Admin and 276 server tests pass; no widget tests were added.
- The same generated query path now carries tag ids and Medusa's JSON
  `created_at` / `updated_at` comparisons. SQL applies them before both count
  and paging; invalid ids, operators, offset-free dates and reversed ranges
  return `400`. Live API QA returned zero rows for an unknown tag and a future
  creation bound, then rejected `$after`. Thirty-three non-widget Admin and 280
  server tests pass; no widget tests were added.
- Product types now follow the pinned Medusa list and product-filter sources:
  a normalized table, guarded `/admin/product-types` discovery, and `type_id`
  filtering live behind the generated Admin client. Store and Admin detail
  responses independently return the display label rather than the internal
  id. Fresh-database API QA proved `401`, search/paging, one matching product,
  malformed-id `400`, and Store readback. Thirty-four non-widget Admin and 284
  server tests pass; all 39 migrations also pass real SQLx run/revert.
- Product query controls now expose source-ordered Type, Tag, Status, Created
  and Updated filters, real discovery choices, removable active controls,
  Clear all and all six supported sort values. The head-to-head pass corrected
  the stretched card, column proportions, row and pagination density, source
  copy, status indicator, menu order, menu size and surface color. Live QA
  filtered the table to Shirt, proved the removal button's accessible label,
  and restored all four products. Thirty-six non-widget Admin and 287 server
  tests pass; all 39 migrations apply and revert without remaining tables.
- Product Types now have the pinned Settings list, create focus modal and edit
  drawer backed by guarded CRUD routes. Product creation and the detail
  Organize drawer select the same stable ids, support explicit Unassigned, and
  refresh the allowlisted product detail after save. Live QA exposed all five
  fixture types, assigned Pants, cleared the type, and restored Shirt; the Store
  boundary still receives only the label. Forty non-widget Admin and 298 server
  tests pass; no widget tests were added.
- Selecting a Product Type now opens the pinned single-column detail layout:
  identity actions, a separately searchable and sortable 10-row Products table,
  then safe Metadata and JSON cards. Live QA opened Shirt with six demo products,
  narrowed the server result to Sample Pocket Tee, reversed and restored title
  order, and opened a linked product detail. Browser logs had no errors. The
  authenticated shell was split below the 180-line gate, reducing legacy LOC
  failures to twelve. Forty-two non-widget Admin tests pass; no widget tests
  were added.
- Product creation now reproduces Medusa's option permutation behavior across
  multiple axes. Live QA generated Size × Color in source order, reduced four
  combinations to two, and proved the surviving S / Black variant retained its
  entered EUR price. A protected integration test round-trips the same complete
  graph. Forty-six non-widget Admin and 299 server tests pass; splitting the
  create screen reduced legacy LOC failures to eleven.
- Product export now opens Medusa's 560px right-side drawer with read-only
  active query controls and sticky Cancel/Export actions. Live QA searched the
  24-product catalogue for `pocket`, observed one matching row and the same
  search/order summary in the drawer, then verified a fresh browser blob named
  `product-export.csv` and the success message. A route-level guarded API uses
  one direct SQLx projection and emits ordered Medusa-shaped CSV fields with
  exact currency exponents and quoting. Forty-seven non-widget Admin and 301
  server tests pass; no widget tests were added and LOC debt remains eleven.
- Product import now opens Medusa's right-side preview drawer with one bounded
  CSV picker, selected-file processing, create/update summary, template
  download and sticky footer. The guarded preview writes only a merchant-owned
  staged transaction; focused tests prove the product count does not change.
  Live QA verified the empty drawer and disabled confirmation state. Forty-nine
  non-widget Admin and 305 server tests pass; the 40-migration schema and
  contract checks plus Dust generation checks pass, and no widget tests were
  added.
- Product import confirmation now has a route-guarded, owner-scoped backend
  operation matching Medusa's `POST /admin/products/import/:id/confirm`
  boundary and 202 empty response. One SQLx transaction applies the complete
  supported product graph, consumes the staged row once, and rolls back on
  conflicts. The generated Admin client, view model, and drawer now submit that
  transaction and refresh the product list after success. Live browser QA
  uploaded `Browser Import Cap`, previewed one create and zero updates,
  completed the import, and rendered the new published product with the success
  message. Direct database verification found its one-size SKU plus exact EUR
  1000 and USD 1500 minor-unit prices. A fresh DTC catalogue reload exposed the
  product at USD 15.00, and its detail route correctly rendered zero inventory
  as out of stock. Admin browser warnings and errors were empty. Eight focused
  preview/confirmation tests, all 310 server tests, and all 50 non-widget Admin
  tests pass. A later live stock pass opened that same imported product through
  Product details, changed its managed one-size variant from zero to 25, and
  immediately exposed Add to cart in the DTC route. Adding one unit produced a
  USD 15.00 cart line and Cart (1). The four protected/atomic server stock tests
  and both non-widget Admin stock-state tests pass; no new widget test was added.
- Orders now open from the selected sidebar row into Medusa's source-ordered
  Order, Date, Customer, Sales channel, Payment, Fulfillment, Total and Country
  table. Search narrowed six rows to Ada; the Completed filter returned three
  rows; removing it restored all six. The narrow drawer closes after navigation,
  the desktop table retains compact 48px rows, and a clean reload produced no
  browser warnings or errors. The generated client keeps the Dio-owned bearer,
  typed `DateTime` and `Option` query state. All 53 non-widget Admin and 314
  server tests pass; Dust checks and the release web build pass.
- Sales-channel order parity now follows Medusa's source hook and cell: the
  Admin loads `id,name` choices through the same Dio bearer owner, exposes a
  searchable multi-select using `sales_channel_id`, carries it into CSV export
  and renders the channel name with `-` only for legacy unlinked orders. Live
  QA on a clean current-schema database showed Online Store and Wholesale,
  then narrowed two labeled rows to the single Wholesale order with `1 — 1 of
  1 results`; browser errors were empty. All 60 non-widget Admin tests and all
  333 server tests pass; Dust, analyzer and the release web build are clean,
  with no widget test added.
- Selecting order #1002 now opens a protected read-only detail with Medusa's
  General, Summary, Payment and Fulfillment main column plus Customer and
  Activity sidebar. Desktop keeps the 7:3 composition and the narrow viewport
  stacks every card. The browser rendered two real item snapshots, an exact
  USD 68.00 total, captured Stripe record, both frozen addresses and persisted
  timestamps; navigation back to Orders remains available. The generated
  feature client shares the Dio-owned bearer and widgets receive only typed
  `Option` values. All 56 non-widget Admin and 318 server tests pass; analyzer,
  Dust checks and the release web build pass, and no widget tests were added.
- Order Export now opens Medusa's 560px right-side drawer with the active order
  query rendered as read-only chips and sticky Cancel/Export actions. Live QA
  narrowed six demo orders to Ada, verified the same query in narrow and
  `1440 x 900` layouts, and produced a browser blob named `order-export.csv`
  with no browser errors. The guarded endpoint reuses list filters and one
  direct SQLx projection, returns one escaped CSV row per frozen item and uses
  exact ISO currency exponents without exposing internal ids or metadata. All
  58 non-widget Admin and 321 server tests pass; analyzer, Dust checks and the
  release web build pass, and no widget tests were added.
- Order Region filtering now loads the real Europe and United States choices
  from a protected direct-SQLx Admin response instead of reusing Store data or
  hard-coding ids. The generated client shares Dio authorization, keeps loading
  and failure state separate from order rows, and the source-shaped submenu is
  searchable and multi-select. Live QA searched for Europe, reduced six orders
  to #1001, #1004 and #1006, verified the `Region: Europe` chip and export
  summary at narrow and desktop widths, then completed a clean reload with no
  new browser errors. All 59 non-widget Admin and 324 server tests pass;
  analyzer, Dust checks and the release web build pass.
- Product list and detail now expose active sales-channel assignments as typed
  `id,name` objects from direct SQLx projections. The list follows Medusa's
  source cell exactly: no assignment renders `—`, one or two channels render
  their names, and additional channels render the first two plus `+N more`
  with the remaining names in the tooltip. QA linked Browser Import Cap to
  Marketplace, Online Store and Retail and observed `Marketplace, Online
  Store +1 more`; a completely fresh Flutter process loaded with no new browser
  errors. All 63 non-widget Admin and 340 server tests pass; Dust checks,
  analyzers and the release web build are clean. Shipping-profile assignment
  remains a separate unimplemented slice.
- Product sales-channel editing now mirrors Medusa's pinned source structure:
  a full-screen focus modal, autofocus search with 250ms debounce, 50-row
  server paging, cross-page selection, Name, Description, Status, Created At
  and Updated At columns, and a complete-selection save. Live QA assigned both
  Online Store and Wholesale to Classic White Tee, observed `2 of 2` on the
  detail page, reopened the editor, and narrowed the server result to Wholesale.
  The final fresh build retained both selections and the theme-token status
  treatment. All 66 non-widget Admin tests pass; analyzer, Dust and the release
  web build are clean. Widget subtrees in this slice are concrete widget
  classes rather than private methods returning `Widget`.
- Product shipping-profile editing now follows Medusa's source hierarchy: a
  Shipping Profile card, merchant label and type, right-side drawer, searchable
  server choices, explicit Unassigned state, and sticky Cancel/Save actions.
  Live QA changed Default Shipping Profile to Fragile Goods, then cleared the
  assignment; the card refreshed after each save and browser warnings/errors
  remained empty. All 70 non-widget Admin and 354 server tests pass; analyzer,
  Dust, the widget-composition guard and the release web build are clean. The
  touched sidebar's two private `Widget` builders were replaced with concrete
  widget classes and removed from the frozen debt baseline.
- Shipping-profile settings now provide real list, create, detail and delete
  navigation, including the previously decorative product-card destination.
  Every new visual responsibility is a concrete widget class; no private method
  returns `Widget`. Live create/delete and product-link journeys passed at
  `1280 x 720`, while the official source comparison exposed the remaining
  filter/order control gap.
- Requested-return receipt follows the pinned order Summary rather than adding
  a standalone Returns page. Live QA rendered `Receive return` for return `#1`,
  then opened intact, damaged and notification inputs and canceled without
  consuming the reusable fixture. The protected command advances partial or
  final status atomically and restores only intact managed inventory; damaged
  and unmanaged units remain out of stock. All 82 non-widget Admin tests and
  all 386 server tests pass; analyzers and both Dust check modes are clean.
- Fulfillment shipment follows the pinned order-detail card and create-shipment
  focus form. Live QA created a guest storefront cart and captured order #1,
  created its fulfillment in Admin, added `MORROW-TRACK-001`, and observed the
  refreshed order and fulfillment badges change to Shipped. The saved tracking
  number rendered in the card and both lifecycle actions became disabled.
  Database and authenticated API reads confirmed the database-owned shipment
  timestamp, authenticated admin actor and one persisted carrier label. All 97
  non-widget Admin tests and all 424 server tests pass; analyzer, Dust checks,
  the widget-composition baseline and release web build are clean. Every new
  shipment subtree is a dedicated widget class; no widget test was added.
- Fulfillment delivery follows the same pinned order-detail source. Live QA on
  order #1 opened the `Are you sure?` prompt, rendered Medusa's irreversible
  warning, showed the unavailable notification switch disabled, and continued
  once. The order and fulfillment badges refreshed from Shipped to Delivered,
  while SQLite retained `shipped_at`, `MORROW-TRACK-001` and generated UTC
  `delivered_at` value `2026-09-14T00:10:07.063Z`. The terminal card removed
  both lifecycle actions. All 100 non-widget Admin tests and all 429 server
  tests pass; analyzer, Dust checks and the Admin release web build are clean.
  The action and prompt are dedicated widget classes; no widget test was added.
  Accessibility enablement emitted Flutter route-label warnings before the
  mutation, but delivery emitted no new warning or error.
- Fulfillment cancellation follows the pinned card action and cancel route.
  Live QA created a real guest Store cart for two Essential T-Shirts, selected
  Standard shipping and manual payment, placed and captured order #1, then
  created its pending manual fulfillment in Admin. The card action opened the
  exact `Are you sure?` warning and continued once. The refreshed order changed
  from Fulfilled to Not fulfilled, retained Fulfillment #1 as Canceled, disabled
  its Cancel action and exposed Create fulfillment again; reopening the form
  offered the original `2 / 2` units. SQLite stored
  `2026-09-14T00:34:07.240Z` and `owner@morrow.local` as the cancellation actor,
  with shipped and delivered timestamps absent. All 104 non-widget Admin, 435
  server and 11 Admin-contract tests pass; analyzers and all Dust checks are
  clean. New UI subtrees are widget classes and no widget test was added.
  Browser logs contained only the pre-existing Flutter route-label warnings,
  with no cancellation warning or error.
- Customers now follows the pinned list container, four visible columns,
  search, filter, sorting and 20-row paging structure. Live QA created four
  registered profiles through the Store API and one guest through a complete
  checkout, then rendered all five in Admin. Search, Registered/Guest filters,
  email ordering, Clear all and `390 x 844` responsive behavior passed; final
  browser warnings and errors were empty. The Create control is honestly
  disabled because create/detail/groups remain separate capabilities. This is
  source-structure and behavior evidence, not same-state pixel parity with a
  running Medusa Admin.
- Customer detail now follows the pinned General and Orders main column plus
  440 px Addresses side column. Live QA showed Ada's Store-created default
  address and authenticated order `#4`, opened the full order and returned to
  Ada's detail. The final release build used the two-column grid at the default
  1280 viewport, collapsed at `390 x 844`, and emitted no browser warning or
  error. Edit/delete, address mutations and groups stay disabled or absent
  rather than pretending the API exists. No equivalent live Medusa customer
  fixture was available, so same-state pixel parity is not claimed.
- Customer-group edit now follows the pinned General-card action and 560 px
  right-side drawer. Live QA opened Edit, validated empty input, renamed VIP
  Customers to VIP Members, restored the normalized canonical name, observed
  the exact success message and confirmed SQLite advanced its database-owned
  timestamp. Compact and `1440 x 1000` layouts, Escape dismissal and final
  browser logs passed. All 146 non-widget Admin and 527 server tests pass; both
  Dust modes and analyzers are clean, and no widget test was added.
- Customer-group membership now follows the pinned full-screen 10-row selector
  and selectable detail table. Live QA added Dorothy Vaughan to VIP Customers,
  showed the exact singular success message, refreshed the count from two to
  three, and persisted the authenticated Admin actor with database-generated
  UTC timestamps. Existing members stayed checked and disabled with the exact
  tooltip. The per-row Remove action opened the exact singular irreversible
  prompt and was canceled to preserve the fixture; server integration proves
  removal and rollback. All 151 non-widget Admin and 537 server tests pass;
  Dust, analyzers, release build, structure and size gates are clean.

## Open findings

- P2 — Capture an unletterboxed Medusa source at the same content width before
  declaring pixel parity. The current combined comparison passes structural
  design QA, not a pixel-diff threshold.
- P2 — Product-list channel behavior passes, but whole-screen parity still has
  visible density and asset drift: Morrow uses a wider sidebar and taller rows,
  while several local demo thumbnails fall back to placeholders.
- P3 — Global option creation uses comma entry rather than Medusa's interactive
  chip input and post-entry rank organizer. Persisted ordering works, but this
  interaction is not yet a literal copy.
- P3 — The global list keeps its required Global filter as one fixed chip;
  Medusa's removable segmented filter and Clear all interaction are not yet
  implemented.
- P2 — The post-create editor lacks a same-state rendered Medusa source capture.
  The implementation matches the pinned source structure—full focus modal,
  four-column gallery, 24px grid gap, 560px upload panel and sticky footer—but
  code inspection is not a pixel comparison. Run Medusa Admin locally with
  equivalent product data, capture both editors, and repeat the combined pass.
- P1 — The filesystem adapter is durable for one server node. Multi-node
  deployment still needs object storage and cleanup for uploads left staged
  after an abandoned browser session.
- P2 — Orders pass source-structure and live-behavior QA, but need same-state
  Medusa order-list and order-detail captures before pixel parity can be
  claimed. Sales-channel discovery, order query behavior and the source-shaped
  visible filter are implemented, while channel mutations remain separate.
  Fulfillment, shipment, delivery, cancellation and independent manual-payment
  refund behavior now pass live QA against the pinned source structure, but
  their forms and prompts also lack same-state Medusa captures. External refund
  provider adapters remain separate.
  Region and Order Export have source-structure and live-behavior coverage but
  also lack same-state Medusa captures.
- P2 — Shipping-profile assignment passes source-structure and live-behavior
  QA, but needs an equivalent live Medusa product/profile state and combined
  capture before pixel parity can be claimed.
## Result

Passed for the implemented product-list, product-detail, general-edit,
product-create-with-media, post-create media-card, image-variant and
variant-detail, product-option-edit and global product-option behavior slices.
Variant-detail, product-option-edit and global product-option list/detail visual
parity now pass same-state live comparisons. Global product-option creation
also passes its same-state empty-form comparison.
Variant pricing, product stock and product deletion pass source-structure and
live end-to-end behavior checks. Product query behavior, discovery and visible
controls pass API, state, accessibility and same-state live comparison.
The order list, region filtering, detail, fulfillment shipment, delivery,
cancellation, independent manual-payment refunds and filtered CSV export pass
protected API, generated-client, responsive layout and live-data behavior
checks against the pinned source structure.
The customer list, detail, mutations, address create/read/update/delete, and
customer-group list/create/detail/edit/delete/membership flows pass protected
API, explicit-contract, direct-SQLx, responsive layout and live data checks
against the pinned source structure. The address update is API-only because the
pinned dashboard exposes no Edit action. Same-state customer raster parity
remains open.
Customer-group Created and Updated filtering passes the pinned Add-filter,
preset, Custom, active-chip and clear interaction structure. Live API-backed QA
covered both filters, the empty state and an inclusive same-day custom range;
pixel parity remains unclaimed without a same-state Medusa raster.
The product-list sales-channel slice passes its typed contract, direct SQLx
projection, source-shaped truncation/tooltip behavior and clean-start browser
QA. Its whole-screen density and thumbnail differences remain an open visual
finding.
Product sales-channel editing passes typed state, direct authenticated API,
complete-selection mutation and live browser behavior against the pinned
Medusa source structure; same-state source raster comparison remains open.
Product shipping-profile editing passes protected list/update behavior, typed
`Option` state, source-shaped card/drawer composition and live replace/clear
QA; same-state Medusa raster comparison remains open.
Shipping-profile settings pass protected CRUD and query behavior, typed
ViewModel state, product-card navigation and the live merchant journey. The
Add filter, active chips, Clear all and order menu match the source structure;
same-state combined source capture remains open.
Post-create editor, image-variant drawer, variant pricing, product stock and
product deletion and orders remain blocked on same-state source captures;
broader Medusa Admin parity is not claimed.

final result: blocked
