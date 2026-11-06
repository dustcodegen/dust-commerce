# Medusa admin parity

The implementation target is Medusa's admin API and dashboard at source commit
`bda24b9725ac697ec5e8f706b503013e20babf12`. Work is feature-first: a row is
not complete until its real API, authorization, failure states, generated Dust
output, analyzer, and tests pass. Visual comparison follows the working slice.

This document is the current admin parity ledger. The public repository
currently has no linked issue or milestone for this work, so status claims here
must be backed by the source, authorization checks and tests recorded below.

The product-specific Customer Service extension is tracked separately in
[customer-service-qa.md](customer-service-qa.md) so it is not mislabeled as a
Medusa Admin source-parity feature.

The repository's 180-code-line gate still reports 6 legacy files. New slices
add no over-limit handwritten file, and touched legacy files are split by
responsibility. The remaining debt stays visible instead of weakening the gate.

## Current local package gate

On 2026-11-06 at `f18c474d`, `./scripts/verify_package.sh apps/admin_app`
completed with Dust `261/261` clean, Flutter analysis clean, and `175` Admin
non-widget tests passing. No widget tests were added; CI and remote merge remain
deferred until the one-day local review window ends.

## Promotion creation slice

`POST /admin/promotions` now closes the first write gap in the protected
promotion surface. The route uses the existing route-level `AdminAuth` guard,
an explicit generated `AdminCreatePromotion` body allowlist, normalized
uppercase codes and lowercase currencies, and one direct SQLx `INSERT ...
RETURNING` projection. Percentage values are bounded to basis points, fixed
values require a currency, percentage policies reject a currency, date windows
must be increasing, and active code conflicts return `409` without a partial
row. PostgreSQL owns the promotion timestamps and the response remains the
standalone Admin allowlist rather than inheriting persistence fields.

The focused PostgreSQL route gate covers unauthenticated access, normalized
percentage and fixed creation, scheduled status, duplicate codes, invalid
cross-field definitions, and no-write rejection. The generated Admin client
exposes the body-only create method; bearer ownership remains in Dio. The
Admin promotions page now has a focused create surface for code, type, value,
currency, and usage limit, with server-owned error handling and a generated
client integration test that returns to the newly created detail route.

## Promotion retirement slice

`DELETE /admin/promotions/{id}` now retires one active promotion behind the
same route-level Admin bearer guard. The direct SQLx update sets the existing
`deleted_at` audit field with PostgreSQL time, returns a standalone
`{id, object, deleted}` acknowledgement, hides the row from Admin reads, and
leaves redemption history intact. The generated Admin client and detail route
include confirmation, safe failure copy, and a server-authoritative loading
state. Focused PostgreSQL coverage verifies authorization, soft deletion,
repeat/missing failures, and the refreshed hidden detail; the Admin package
gate covers the generated client and ViewModel flow without widget tests.

## Promotion editing slice

`PATCH /admin/promotions/{id}` updates the editable promotion definition
behind the same route-level Admin bearer guard. The request is an explicit
generated allowlist, values are normalized and revalidated server-side, and a
single direct SQLx `UPDATE ... RETURNING` projection preserves committed
redemptions while preventing duplicate active codes or a usage limit below the
current usage count. The response is the standalone Admin detail contract.

The generated Admin client, detail ViewModel, and focused edit form cover
successful updates plus safe 401, 404, 409, and 422 handling. PostgreSQL still
owns audit timestamps; the route never accepts internal columns or persistence
fields. The server and Admin package gates include the update path without
widget tests.

## Staged-media cleanup slice

Admin uploads now perform a best-effort cleanup pass before accepting new
multipart data. The direct SQLx media projection supplies only active product
image URLs; the local adapter protects claimed files and removes unreferenced
files older than one hour, including abandoned staged files. Cleanup failures
never reject a valid upload and only generated asset or pending names are
eligible for deletion, so unrelated files in the media root are preserved. The
focused media gate covers authorization, public reads, attached-file
protection, invalid uploads, missing-key rejection, old-orphan reclamation,
and foreign-file safety; object storage remains the separate multi-node
boundary.

## Isolation boundary

- `apps/commerce_app` is the customer storefront on port `13001`.
- `apps/admin_app` is the merchant application on port `13002`.
- `packages/commerce_shared` contains customer/store contracts only.
- `packages/commerce_admin_shared` contains admin contracts only.
- Customer and admin identities use distinct auth providers and secure-storage
  keys. A token for one actor type cannot enter the other route tree.

The first slice uses route-level `AdminAuth`, composed from Dust Server's
`BearerTokenExtractable`. Flutter attaches the bearer once in a Dio interceptor;
generated API methods have no authorization parameter. Passwords use Argon2id,
only token fingerprints are stored, disabled admins lose existing sessions, and
there is no public admin-registration route.

Token expiry is a `DateTime` in Dart and ISO-8601 JSON on the wire. PostgreSQL
keeps the normalized UTC instant as native `TIMESTAMPTZ`. The injected clock
exists only at expiry/security decisions and tests; table audit timestamps are
generated by PostgreSQL.

## Delivery map

| Area | Current status |
| :--- | :--- | :--- |
| Identity, sessions, users, RBAC | bootstrap, sign-in, current user, sign-out, disabled-user denial implemented; RBAC remains |
| Products and catalogue | protected list, search, paging, lifecycle/tag/date/type filtering, product-type and tag discovery, visible query controls, allowlisted ordering, detail, general edit, atomic multi-axis creation, post-create media management, image-to-variant association, variant detail editing, active-currency pricing, aggregate variant stock, product soft deletion, filtered CSV export, end-to-end staged atomic CSV import, and product-type CRUD, assignment, detail and linked-product paging implemented; interaction parity gaps remain |
| Orders and post-purchase | protected list, detail, filtered CSV export, generated Admin client state, search, region/status/date filtering, paging, allowlisted ordering, fulfillment creation and cancellation, shipment creation with carrier labels, delivery marking, requested-return discovery and atomic receipt, whole-order cancellation, and independent manual-payment refunds implemented; external refund providers remain |
| Customers and groups | protected customer list/detail/create/edit/delete, address create/read/update/delete, customer-owned order history and guest-checkout profile acquisition implemented; protected customer-group list/create/detail/edit/delete, group-scoped customer search/account filter/order/paging, Created/Updated preset and custom filtering, atomic add/remove membership, generated client state and Admin navigation implemented; visual comparison remains |
| Inventory and locations | product-level variant stock editing, atomic intact-return restoration, and a protected searchable stock-location list with direct SQLx address allowlist, dedicated generated Admin client, authenticated ViewModel and responsive Inventory/Locations route implemented; inventory items, reservations, location mutations and location detail remain |
| Pricing and promotions | protected promotion list/detail APIs plus guarded code-promotion creation, editing, retirement, search, date filters, ordering, generated Admin client, direct SQLx allowlists, read-only Admin table with paging, and row-to-detail navigation implemented; campaigns remain |
| Regions, shipping, tax, channels | protected sales-channel discovery and product availability editing plus shipping-profile discovery, product assignment, settings CRUD, query controls and Admin navigation implemented; locations, shipping options and tax remain |
| Uploads, notifications, search, translations | guarded streamed image upload, staged deletion, abandoned-upload cleanup and public immutable reads implemented with a single-node filesystem adapter; external object storage and other areas remain |
| Workflows and extension boundaries | not started |
| Flutter admin shell and visual parity | Medusa-shaped shell, product table/detail, responsive layouts and light/dark/system selection implemented; remaining routes and unletterboxed pixel comparison remain |

The customer list follows Medusa's pinned 20-row query and visible Email, Name,
Account and Created columns. Its protected response is a direct SQLx `FromRow`
allowlist, its generated Dio method relies on the shared Admin authorization
interceptor, and its Flutter state uses `Option` for absence. A real Store guest
checkout now atomically upserts a non-authenticating customer profile while
leaving the order unclaimed for the existing transfer flow. Search,
registered/guest filters, ordering and desktop/compact rendering pass live QA.
The customer detail follows Medusa's General, Orders and Addresses
composition. One guarded direct SQLx projection returns only the customer
allowlist and active addresses; the existing order query applies a validated
customer id before count and paging. The generated Admin client keeps bearer
ownership in Dio, and profile/order state uses `Option` for absence. Live QA
proved a Store-created address and authenticated order appear for the same
customer, order detail returns to that customer, the default viewport uses the
440 px side grid, and `390 x 844` collapses cleanly. Creation and the
source-shaped edit drawer are functional. Edit uses one guarded transaction, a
direct final response, immutable registered-account email ownership, nullable
contact replacement, Dio-level Authorization and database-owned timestamps.
Deletion now follows Medusa's separate destructive action group and exact
typed-confirmation flow. One guarded SQLx transaction soft-deletes the customer
and addresses, preserves order history, revokes an exclusive authentication
identity or detaches only the customer actor from a shared identity, and fails
closed on inconsistent registered ownership. Its explicit acknowledgement is
retained through generated Dio transport and `Option` state. Address creation
now follows Medusa's full-screen focus form, complete country list and exact
locale copy. Its route guard and explicit Admin extraction protect a strict
standalone input, one flat SQLx transaction writes the final
`customer_addresses` table, PostgreSQL owns both UTC timestamps, and the direct
customer response refreshes the detail page. Address deletion now matches
Medusa's delete-only row menu, typed verification and detail refresh.
Its route-level guard and explicit Admin extraction protect one ownership-bound
soft delete; the direct SQLx acknowledgement returns the refreshed parent through
one flat `Result`, and Dio remains the only bearer owner. Address update now
matches Medusa's partial `POST` contract without inventing an Edit control that
the pinned dashboard does not expose. A strict tri-state patch distinguishes an
omitted field from an explicit JSON `null`; one guarded SQLx transaction enforces
active parent ownership, lets PostgreSQL switch defaults and generate `updated_at`,
and returns the refreshed direct customer response through
`Result<Option<AdminCustomerDetailResponse>, SqlxError>`. The generated client
keeps Authorization at Dio level, and its real client-to-server test covers
partial preservation and explicit clearing.

Customer-group discovery now follows Medusa's pinned 10-row list. Two reversible
one-table migrations own the final group and membership schemas with inline
comments, database-generated UTC timestamps, active uniqueness and soft-delete
history. The guarded handler also requires the authenticated Admin extractor;
one direct SQLx projection returns only group identity, name, typed timestamps
and active customer ids through a flat `Result`. Search, both date filters and
six allowlisted order values apply before count and paging. A dedicated generated
Dio client owns no bearer parameter, and dedicated Dust state uses `Option` for
failure. The functional Flutter route renders the source's Name, Customers,
Created and Updated columns with visible local time, exact empty-state copy,
responsive navigation and working query controls. Customer-group creation now
uses a strict standalone input, guarded direct SQLx insert, database-owned
timestamps, actor audit ownership, generated body-only Dio method, dedicated
`Option` state and the pinned 720 px route-focus form. Live QA verified
validation, normalized persistence, initial list refresh, exact success copy,
compact and desktop layout, and functional Escape dismissal. Same-state Medusa
customer raster comparison remains an explicit gap; unsupported actions are not
exposed as fake controls.

Customer-group Created and Updated controls now match the pinned source menu
structure: Add filter lists only inactive fields, each field exposes the five
Medusa presets plus Custom, active chips reopen their choices, and each chip or
Clear all removes real query state. Local-calendar presets and inclusive custom
end dates become typed JSON comparisons applied before SQL count and paging.
Live QA covered both fields, the zero-result state and a same-day custom range;
the Custom dialog uses a stable root navigator after its menu overlay closes.

Customer-group detail now follows Medusa's single-column General, Customers,
Metadata and JSON composition. A guarded direct SQLx projection returns only
the standalone detail allowlist, active customer ids, optional metadata and
typed database timestamps. The existing customer list accepts the group's id
inside both its row and count SQL, excluding deleted groups, memberships and
customers before paging. Generated Dio methods carry no authorization argument;
dedicated Dust state uses `Option` for detail and failures while the customer
section loads independently. The Flutter route provides real list-row and
post-create navigation, customer search, registered/guest filtering, all
allowlisted ordering, 10-row paging and navigation into customer detail.
Compact and `1440 x 1000` release-browser passes showed the same source section
order and no console errors. Membership management now adds from a full-screen
10-row selector, preserves selection across queries, disables existing members,
and removes through selected-row or per-row actions. One guarded atomic batch
validates active customers, records the authenticated actor, uses PostgreSQL-owned
timestamps, and returns the refreshed direct detail projection through one flat
`Result`. Live addition and the removal confirmation passed; the destructive
live removal was canceled to preserve the reusable fixture.

Customer-group editing now matches Medusa's authenticated POST boundary and
one-field RouteDrawer. A strict standalone input accepts only the normalized
name; one flat SQLx transaction updates the active final-schema row and refetches
the direct detail response while PostgreSQL owns `updated_at`. The generated Admin
client relies on Dio-level authorization, and dedicated command state uses
`Option` for success and failure. Live QA covered Escape, local validation,
trimmed rename, exact success copy, compact and desktop layout, database
persistence and an empty browser warning/error log.

Customer-group deletion now follows Medusa's separate destructive action group,
confirmation copy, acknowledgement shape and refreshed-list success flow. The
route-level Admin guard and explicit extractor protect one flat SQLx transaction
that soft-deletes the active group and all active memberships while retaining
customer records. PostgreSQL owns deletion and update timestamps; no migration or
application clock was added. Generated Dio owns no bearer parameter, dedicated
command state uses `Option`, and live QA proved Cancel, confirmed deletion,
membership retirement, customer preservation, exact success copy, name reuse
availability and a clean healthy-load browser console.

The current product list and detail use the existing final product, collection,
image, option, variant, category and tag tables. Both responses are direct SQLx
`FromRow` projections with explicit admin allowlists; the complete detail uses
ordered PostgreSQL JSON subqueries in the same row instead of introducing an ORM or
mapping through an internal model. It does not reuse the storefront contract or
expose metadata, deletion markers, auth data, or other internal fields.

General edit updates title, subtitle, handle, material, description,
discountability and lifecycle status through a protected route-level-guarded
API. Handle conflicts are race-safe, optional blank values clear to SQL `NULL`,
and PostgreSQL generates the audit timestamp. The original one-shot `products`
migration owns the final `subtitle` and `discountable` columns with inline
comments; there is no appended `ALTER TABLE` migration.

Product creation follows the pinned Medusa focus flow: Details owns General,
media and option setup, Organize owns the currently supported merchant
attributes, and Variants owns inventory and every active regional price. Media
is streamed and signature-checked before submission; the merchant can reorder,
remove and choose one thumbnail. Publish verifies each server-issued file, then
writes the product, ordered images, option values, variants, selections and
prices in one transaction. Fabricated image keys, duplicate handles or SKUs and
incomplete option/price graphs leave no partial catalogue rows. Attached files
cannot be deleted through the staging endpoint. A published product and its
images are immediately readable through the public storefront contract.

Post-create media management now follows Medusa's full-replacement behavior.
The focused editor uploads real files, supports four-column drag ordering,
multi-select deletion and thumbnail promotion, then sends one ordered gallery.
The server distinguishes retained image row ids from staged storage keys,
claims new files against concurrent attachment/deletion, moves old ranks clear
of PostgreSQL's uniqueness constraint, soft-deletes omitted links, and updates the
thumbnail in the same transaction. Removed file assets remain available to the
storage layer, matching Medusa's association update rather than pretending a
database transaction can atomically delete an external object.

Image-to-variant management now matches Medusa's batch-delta route and focused
drawer. A route-level admin guard protects add/remove operations, the service
rejects overlap and cross-product links atomically, and the final
`product_image_variants` table enforces ownership with foreign keys and a
trigger. Removing product media clears stale associations. The drawer searches,
selects and saves only changed variant ids, then refreshes the explicit admin
detail allowlist.

The separate storefront response exposes ranked `StoreProductImage` objects on
products and their associated variants. It does not import or inherit the admin
image contract. Selecting `v_id` now drives the same gallery filtering as the
current Medusa DTC source.

Variant detail editing now follows Medusa's separate right-side drawer and
route shape. The guarded update replaces the title, optional SKU/barcode,
option selections, inventory policy and backorder policy while intentionally
leaving prices and stock quantity to their own future operations. It validates
complete product-owned selections, rejects duplicate variant combinations and
SKU conflicts before partial writes, relies on PostgreSQL for `updated_at`, returns
the refreshed direct SQLx detail projection, and is immediately visible through
the separate Store product response.

Variant pricing now follows Medusa's dedicated full-screen focus flow: a
read-only variant title, one editable column per active storefront currency and
a sticky Cancel/Save footer. The guarded operation replaces the complete
currency graph atomically, rejects missing, duplicate and unsupported
currencies, relies on PostgreSQL for audit timestamps and returns the refreshed
direct SQLx product projection. Admin inputs use each ISO 4217 currency's real
decimal exponent without floating-point conversion. Browser QA changed both
EUR and USD amounts, observed immediate storefront readback, then restored the
canonical fixture.

Variant stock now follows Medusa's product-level full-screen grid and selected
variant batch boundary without inventing unsupported stock locations. Each row
shows the real title and SKU, inventory-management switch and aggregate units
on hand. The guarded operation rejects empty, duplicate, negative and
cross-product selections before writing, replaces every selected row in one
transaction, relies on PostgreSQL for audit timestamps and returns the refreshed
direct SQLx product projection. Browser QA changed quantity and management
policy, observed immediate storefront readback, then restored the canonical
fixture.

Product deletion now follows Medusa's list-row and detail-card action groups,
confirmation copy, destructive treatment and success/error feedback. The
route-level Admin guard protects one generated `DELETE` client operation. Its
transaction soft-deletes the product, variants, images, option links and
product-exclusive option graph while retaining prices and reusable global
options for history. PostgreSQL generates every deletion and update timestamp;
active handles and SKUs become reusable without an appended migration. The
separate Store read stops returning the product immediately.

Product queries now accept Medusa's comma-separated lifecycle and `tag_id`
filters, JSON `created_at` and `updated_at` comparisons, and six allowlisted
order values. All filtering happens before the count and page boundary. The
timestamp contract accepts `$gt`, `$gte`, `$lt` and `$lte`, requires an explicit
offset, and normalizes the instant to PostgreSQL UTC `TIMESTAMPTZ`. Invalid ids,
comparison objects, status or order values return `400`. The generated Admin
client and ViewModel retain typed query state across paging, search, refresh
and deletion; date bounds are `Option<DateTime>` and Dio still owns the bearer.

Product types now use their own final `product_types` table and `products.type_id`
foreign key. The guarded list route returns only id, label and typed audit
timestamps, while `type_id` filtering applies before count and paging. Store
and Admin product responses continue to expose the merchant-facing label as
`product_type`, so neither contract leaks the persistence identifier. The real
SQLx CLI applies and reverts all 58 migrations without leaving application
tables; no appended migration mutates `products` after creation. Production
entrypoints require that exact successful SQLx history and never replay Dust's
separate embedded-migration ledger.

Product-type management now follows the pinned Settings list, create focus
modal and edit drawer. Guarded generated-client operations search, page, create,
rename and delete only unused types; linked types return a display-safe conflict.
Product creation and the detail Organize drawer use the stable `type_id`, while
the separate Store response still receives only the label. The assignment
operation validates active types, supports explicit clearing, updates only the
organization field and returns a refreshed direct SQLx detail projection.

Selecting a Product Type now opens Medusa's single-column detail route. Its
identity card reuses the real edit and delete operations, while the Products
section independently calls the guarded product list with the stable `type_id`,
10-row server pagination, search and all six allowlisted order values. Linked
rows open the existing product detail. Metadata and JSON cards render only the
explicit Product Type response; no persistence-only field is disclosed.

The product table now exposes Medusa's source-ordered Type, Tag, Status,
Created and Updated filters plus all six supported ordering choices. Type and
tag choices load concurrently from separate guarded, allowlisted discovery
routes; unavailable Sales Channels are omitted instead of fabricated. Active
filters are removable, Clear all preserves search and ordering, pagination
uses the source copy and density, and Dio remains the only bearer owner.

The Sales Channel foundation now matches Medusa's channel fields and nullable
cart/order association semantics without rewriting committed tables. New carts
atomically select the first enabled channel in the current single-store
boundary, and checkout freezes that link onto the order. Protected Admin
discovery now returns only `id` and `name`; order list/export queries accept the
validated Medusa `sales_channel_id` filter and list rows expose the channel
label while preserving legacy channel-less orders. Admin now loads those
choices through its Dio-owned authorization boundary, exposes the searchable
multi-select, includes it in export state and renders the real row label.
Product-channel availability is now enforced on Store list/detail/add/update
against the current single-store channel.

Product creation now follows Medusa's option permutation contract: merchants can
add and remove option axes, comma values normalize without changing first-entry
order, and the variant step generates every left-to-right Cartesian selection.
Each request carries every option title/value pair, while surviving combinations
retain entered SKU, inventory and regional price drafts through option edits.
Focused tests cover ordering and normalization, and a protected API integration
test proves a two-axis, four-variant graph round-trips through the real database.

Filtered product export now follows Medusa's current table query. A route-level
guard protects the static export route, one direct SQLx projection reads each
matching product graph, and the CSV expands ordered variants, options, prices,
tags and images with exact ISO currency exponents and escaped boundaries. The
right-side Admin drawer presents read-only active filters and downloads
`product-export.csv` through the Dio-owned bearer pipeline.

Product import preview now follows Medusa's guarded multipart and drawer flow.
The server accepts one bounded RFC 4180 CSV, validates supported Medusa headers,
typed cells and unambiguous product identities, then stores normalized rows in
the import's own final table. It returns an opaque transaction id and unique
create/update counts without changing the catalogue. The Admin shows the
selected file, server-owned summary and downloadable template; Dio still owns
the bearer.
The protected confirmation route now revalidates the merchant-owned staged
payload and current catalogue identities, then creates or updates product,
variant, option, price, tag and image graphs in one SQLx transaction. Exact
integer minor-unit prices avoid floating-point conversion; expiry, repeated
confirmation, foreign ownership and identity/SKU conflicts are rejected before
catalogue writes. The Admin drawer now sends the staged transaction id through
the generated authenticated client, closes only after a successful `202`,
reloads the product list and reports the result without exposing the response
object.

Order detail now opens from the Medusa-shaped order table through a dedicated
generated Admin client that reuses the Dio authorization interceptor. Its
route-level `AdminAuth` guard and explicit handler extraction protect one SQLx
`FromRow` response projection containing only merchant-safe order facts. Frozen
items, customer addresses and payment fields are nested by ordered JSON
subqueries without an ORM model or a second response conversion. Cart/customer
ids, metadata, provider metadata and deletion fields stay internal. The
responsive Admin route follows Medusa's General, Summary, Payment, Fulfillment,
Customer and Activity hierarchy. It exposes the implemented fulfillment,
shipment, delivery, fulfillment-cancellation, whole-order cancellation and
manual-payment refund mutations. Admin capture and external payment-provider
refund controls remain absent.

Independent payment refunds follow Medusa's payment-level action, strict
optional amount/reason/note contract and exact
`/admin/payments/:id/refund` route. The Admin route guard and explicit
`AuthenticatedAdmin` extraction protect a serialized transaction that rejects
invalid state, reasons and over-refunds before writing. Refund responses are
direct SQLx allowlists, the generated Dio client owns authorization, and the
dedicated right-side drawer reloads the authoritative order after saving.
Partial refunds retain Captured and the remaining action; a full refund changes
the aggregate status to Refunded and disables it. Manual-provider desktop and
390px browser QA passed. Refund reasons now support guarded create, edit and
soft-retire mutations through direct SQLx projections; historical refund rows
retain retired reason data. The Admin app's generated Dio client exposes the
same typed mutation contracts while keeping bearer ownership in its
interceptor. The authenticated Admin shell now exposes a Settings › Refund
Reasons route with search, paging, create, edit and soft-retire controls;
external provider adapters remain unavailable.

Fulfillment shipment now follows Medusa's order-detail lifecycle and focus-form
source. A route-level Admin guard and explicit authenticated-admin extraction
protect the mutation. It validates the exact fulfillment items, order ownership,
physical-shipping requirement and pending lifecycle before one SQLx transaction
sets the database-owned shipment time and inserts safe carrier labels. The
response is the refreshed direct SQLx order projection. The Admin form uses
dedicated widget classes, repeatable tracking rows, responsive three-column
fields and a sticky footer; Dio remains the only bearer owner.

Fulfillment delivery now follows Medusa's active-fulfillment rule and exact
`mark-as-delivered` route: it does not require a prior shipment, so pickup and
digital fulfillment remain possible. The route guard and explicit
`AuthenticatedAdmin` extraction protect one atomic SQLx transition; PostgreSQL
owns the UTC delivery timestamp and the response is the refreshed direct SQLx
order projection. The dedicated confirmation widget repeats Medusa's
irreversible warning, disables customer notification honestly until an adapter
exists, and disappears after delivery. The transaction outcome is separate
from its single public `Result`, preventing nested `Result<Result<...>>` types.

Fulfillment cancellation now follows Medusa's fulfillment-card action and exact
`/admin/orders/:id/fulfillments/:fulfillment_id/cancel` route. Only an active,
pending manual fulfillment can be canceled; shipped, delivered, already
canceled, foreign and externally provided records are rejected before a write.
The route guard supplies an explicit `AuthenticatedAdmin`, and one SQLx
transaction stores PostgreSQL's UTC `canceled_at`, the authenticated `canceled_by`
actor and returns the refreshed direct SQLx order projection. The order returns
to Not fulfilled and canceled quantities become available for a replacement
fulfillment. The dedicated menu action and confirmation widgets use Medusa's
irreversible copy, send `no_notification: true` while no notification adapter
exists, and keep the public failure boundary flat.

Requested-return receipt follows the pinned order-detail source rather than
inventing a standalone Returns page. A protected list query feeds the Summary
action, a generated Admin-only client carries the typed command through Dio,
and every response is a direct SQLx allowlist rather than an internal model.
The receipt transaction validates every intact and damaged quantity before its
first write, advances partial or final status, relies on PostgreSQL for the receipt
timestamp and restores only intact units to active managed variants. Damaged,
unmanaged, deleted and missing historical variants are never added to stock.

Filtered order export now reuses the exact active table query through a static,
route-level guarded endpoint and the same Dio-owned bearer pipeline. One direct
SQLx `FromRow` projection emits one RFC 4180 row per frozen item, including the
merchant-safe order, address and payment fields that exist in the current
schema. Exact ISO currency exponents preserve integer minor units; cart and
customer ids, metadata, provider metadata and deletion fields remain internal.
The Admin drawer is read-only, shows the current filters and saves
`order-export.csv` without changing list state.

Order filtering now loads active selling-region choices from its own protected
`/admin/regions` discovery route, matching Medusa's separate `id,name` request.
The server response is a direct SQLx `FromRow` allowlist and the Flutter client
uses a dedicated generated API over the existing Dio bearer interceptor; it
does not reuse or disclose the richer Store region contract. The searchable,
multi-select Region control sends stable ids while rendering merchant-facing
names in the table toolbar and export drawer.

Product Sales Channels and Shipping configuration now use their actual schemas,
protected APIs and generated Admin clients. The selected shipping profile can be
searched, assigned or cleared, and its product card opens the real Shipping
Profiles settings detail. The settings slice searches, pages, creates, reads and
atomically soft-deletes profiles and active product links through direct SQLx
responses and Dio-owned authorization. The visible query bar filters by name,
type, creation time and update time, and supports eight allowlisted server
orders. Invalid date objects and order values return `400`; filtering precedes
count and paging. Schema growth must remain one final table per reversible
migration, without appended `ALTER TABLE` migrations.
