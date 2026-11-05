# Compared with Medusa

What this project takes from [Medusa](https://github.com/medusajs/medusa), what
it does differently, and — first, because it is the part a comparison usually
hides — how much of Medusa it does not attempt.

Checked head to head against Medusa source commit
`bda24b9725ac697ec5e8f706b503013e20babf12` from 2026-09-04. The comparison
uses the customer and auth models/migrations, email/password provider, and
registration flow at that commit rather than relying on recollection.

## Scale, before anything else

Medusa is a modular commerce platform. This project is a **showcase of Dust
code generation built on a Medusa-shaped domain**, not an alternative to
Medusa. It implements only the path from catalog to cart, checkout, manual
payment, and a basic customer account.

| | Medusa | dust-commerce |
| :--- | :--- | :--- |
| Schema | modular PostgreSQL schemas | one PostgreSQL schema with 59 reversible tables |
| Admin API | broad modular API | isolated identity and product-management slices (22 protected generated-client operations plus public media reads) |
| Generated client operations | broad Store API | 39 method/path operations |
| Workflow engine and plugins | yes | none |
| Admin dashboard | broad operational UI | authenticated product list, detail, edit and creation slices |

## Where the model genuinely agrees

These are the decisions worth copying, and each one is enforced by a test here.

### A line item denormalises what it was bought at

Medusa's `LineItem` carries `unit_price`, `product_title`, `variant_title`,
`variant_sku` and `variant_option_values` as its own columns. Their docs give
the reason plainly: it *"allows line items to retain product/variant
information independently of whether the source data changes."*

Same here, same reason. `LineItem.fromVariant` takes the price at the moment of
adding and nothing reads it again. The test does not trust the code: it adds a
line, updates `variant_prices` in the database, reloads the cart over HTTP, and
asserts the line and the subtotal did not move.

### The variant is the sellable thing

Price and stock hang off `ProductVariant`, not `Product`, in both. A medium
black shirt and a large black shirt are separately counted and shipped, and a
model that prices the product cannot say that.

### Options are an axis on the product, values a choice on the variant

`ProductOption` holds the permitted values; each variant records the value it
chose. That is what lets a storefront render a size selector without inspecting
every variant to discover the sizes, and `Product.variantFor({'opt_size':
'Large'})` is the call a selector makes.

### A region fixes currency and tax

A cart belongs to a region, and that decides the currency every line must be
priced in and the rule the total is computed under — rather than being looked
up at checkout, where it could disagree with what was displayed.

### Customer data and provider credentials are separate

Both schemas keep the customer profile apart from authentication. The account
path creates `customers`, `auth_identity`, and `provider_identity` records in
one transaction. The customer has Medusa's `has_account` distinction and its
active uniqueness rule on `(email, has_account)`, so one guest and one account
record may share an email without permitting two active accounts.

`provider_identity` owns the provider-scoped identifier and provider metadata;
`auth_identity.app_metadata` links the authenticated actor to the customer.
That keeps a later provider from forcing credential columns onto `customers`.

## Where this project deliberately differs

### Money is an integer, and only an integer

Medusa uses a `BigNumber` property for amounts. This project uses a plain `int`
count of the currency's minor unit, divided by a hundred in exactly one place
at the edge of the UI. It is a narrower choice — it cannot express a fractional
minor unit, which some tax and multi-currency work wants — and it is deliberate:
the arithmetic is exact, and every layer that is not the renderer is incapable
of introducing a rounding error.

Tax rounds half away from zero, pinned by a test at 8.75% of 1999, where
truncation under-collects by one unit on every line of every order.

### Prices live on the variant, not in a pricing module

Medusa separates Pricing into its own module, which is what buys price lists,
customer-group pricing and quantity breaks. Here a variant simply has at most
one price per currency, enforced by the primary key `(variant_id,
currency_code)` rather than by convention. Simpler, and correspondingly less
capable.

### Stock is a column, not an Inventory module

Medusa has Inventory and Stock Location modules, so one variant can be stocked
in several places. Here `inventory_quantity` is a column on the variant, and
stock is taken by a conditional `UPDATE` inside the checkout transaction. That
handles the race — two checkouts for the last unit, only one wins, and a zero
row count is how the loser finds out — but it cannot answer *which warehouse*.
Before that write, checkout requires the cart's selected shipping-method
snapshot; bypassing Medusa's Review readiness flow cannot create an order or
consume stock without a delivery choice.

### The order is frozen harder

Every amount on an order is stored. Lines and addresses are copied, not
referenced, so editing an account's address later cannot rewrite where
something was already shipped. Medusa denormalises heavily too; this project
takes it further by storing `subtotal`, `tax` and `total` rather than deriving
them, and the assembler reads them back rather than recomputing. Like Medusa,
the public receipt has a short monotonic display number while the opaque id
remains the API and ownership key. Payment-provider metadata stays private;
the order response joins only provider id, amount and payment creation time for
the customer-facing confirmation.

### Password hashing is Argon2id, not Medusa's current scrypt provider

At the pinned commit, Medusa's email/password provider imports `scrypt-kdf`.
This project deliberately uses `cryptography`'s Argon2id with 19 MiB memory,
two iterations, one lane, a fresh 16-byte secure salt, and a 32-byte result. It
stores the self-describing PHC string in provider metadata and never stores or
serializes the plaintext password.

### Sessions are small and revocable

Instead of Medusa's wider token/session machinery, this service issues a
256-bit opaque bearer token with a seven-day expiry. Only its SHA-256
fingerprint is stored, so reading the database cannot replay a live session;
sign-out deletes the fingerprint. Unknown-email and wrong-password sign-in do
the same Argon2 work and return the same response.

Required account and order routers use Dust Server's Axum-style
`routeLayer(fromExtractor(CustomerAuth()))`; handlers read the resulting typed
extension instead of authenticating independently. `CustomerAuth` composes
`BearerTokenExtractable` for standards-correct parsing, then fingerprints the
token, checks expiry, and resolves the customer. Cart-id routes use one shared
ownership extractor, so every read and mutation hides another customer's cart.

### Email verification is optional, explicit, and single-use

Medusa's DTC registration flow can require email verification before issuing a
customer session. This service keeps that production switch explicit so an
existing deployment cannot silently lock out current accounts. When enabled,
registration creates one expiring capability, stores only its SHA-256
fingerprint, and sends the raw token through the configured TLS SMTP adapter.
Correct credentials rotate a lost link without issuing a session. Confirmation
is a POST, consumes the capability once, and gives expired, replayed, and
unknown links the same response. Existing identities without a verification row
retain their earlier sign-in behavior.
Payment routes use the optional auth layer: customer-owned orders require their
owner, while guest orders retain capability access. Guest carts still work,
but a malformed or invalid header is rejected instead of silently becoming a
guest.

Argon2 admission is capped at two concurrent operations per server isolate.
Excess registration or sign-in work receives `429` immediately instead of
building an attacker-controlled memory queue. The generated Flutter client
keeps authorization at the Dio layer, so one default header or interceptor
covers every protected request without token parameters in each API method.

Admin authentication is a separate actor boundary, not an extra customer role.
It uses its own contract package, provider name, secure-storage key, Axum-style
route guard, generated client, and Flutter app. The bootstrap command is not an
HTTP route. It accepts the initial password only through the process environment
and stores an Argon2id PHC value. Admin token expiry is a Dart `DateTime`; Dust
serializes it as ISO-8601 JSON, while persistence stores the instant in
PostgreSQL `TIMESTAMPTZ` columns.

The product-creation slice copies Medusa's full-screen Details, Organize and
Variants progression while keeping a smaller domain. One guarded request writes
the product, ordered uploaded media, options, option values, variants,
selections and regional prices atomically; a published result is immediately
readable through the separate storefront DTO. Uploads are streamed through a
protected multipart route, restricted by byte signature and size, and served
from a durable single-node filesystem adapter. Medusa additionally creates
sales-channel, shipping, type, collection, category, tag and richer pricing
relationships. Those are not silently fabricated here.

The post-create media slice copies Medusa's complete gallery replacement:
retained image ids, new upload ids, display order and thumbnail travel in one
admin-only request. PostgreSQL shifts historical ranks before compacting active
ones, then soft-deletes omitted links and updates the product thumbnail in the
same transaction. The Flutter focus surface supports upload, grid drag-order,
selection, deletion and thumbnail promotion. A second guarded batch operation
adds and removes image-to-variant links atomically; the Flutter drawer searches
and selects variants, while the separate Store contract returns ranked product
images and each variant's associated images. The product page uses Medusa's
`v_id` fallback and filtering behavior. External object storage remains an
explicit Medusa capability not implemented here.

The post-create variant detail slice also keeps Medusa's operation boundaries:
one guarded variant route and right-side drawer edit title, SKU, barcode,
option selections, inventory policy and backorder policy, while prices and
stock quantity remain separate concerns. Dust maps the refreshed admin detail
directly from its SQL allowlist, and the Store query reads the same committed
variant independently. Complete option ownership, unique combinations and SKU
conflicts are enforced before partial writes.

Variant pricing and stock remain separate operations as they are in Medusa.
Pricing replaces the complete active-currency graph using integer minor units.
Stock uses a product-level batch route and full-screen grid, but deliberately
stores one aggregate quantity per variant because this project has no Inventory
or Stock Location modules. The transaction validates every selected variant
before changing any row, and the public Store projection reads the committed
quantity independently.

Product deletion keeps Medusa's soft-delete semantics but applies them to this
project's smaller graph in one guarded transaction. Products, variants, images,
option memberships and product-exclusive option definitions remain as
historical rows; reusable global options and immutable variant prices are not
retired. Active handle and SKU indexes release identifiers immediately, and
the separate Store query excludes the deleted graph. All timestamps come from
PostgreSQL defaults and update triggers rather than an application clock or an
appended migration.

Admin product queries use Medusa's `status`, `tag_id`, timestamp-comparison and
`order` parameter shapes. The server validates identifiers and every date
operator before SQL, normalizes offset-bearing instants to UTC, applies the
same filters to page and count, and adds a stable id tie-breaker. The generated
Flutter client sends typed tag and `Option<DateTime>` state while its Dio
interceptor remains the only owner of the bearer header. This narrower slice
also normalizes product types behind `products.type_id`, provides a guarded
allowlisted discovery route, and filters by the same Medusa query key before
count and paging. A separate guarded tag-discovery route now supplies the
visible source-ordered Type, Tag, Status, Created and Updated controls. Active
filters, Clear all, source pagination copy and all six supported sort choices
are wired. Sales Channel now has final channel, cart-link and order-snapshot
tables plus protected discovery and real order list/export filtering. The
visible searchable order control, export summary and row label are wired;
Store list, detail, add-line and quantity recheck now enforce the current
single-store channel's product availability.
Product-type CRUD/assignment remains outside the implemented boundary.

Admin promotions now expose the first pricing-and-promotions slice:
`GET /admin/promotions` follows Medusa's protected list boundary with `q`,
`created_at`, `updated_at`, `order`, `limit` and `offset` query parameters.
Rows are direct SQLx allowlists from the final `promotions` table and contain
only code, method, derived status, policy value, optional schedule/limit fields
and database-owned timestamps. This intentionally stops at list/read parity;
campaigns, rule editing, creation, deletion and visual table parity remain
separate slices.

### Order transfers keep the capability out of the database

The three Store routes match Medusa's request, accept and decline shape, while
the storage boundary is deliberately narrower. A target customer makes the
request through route-level authentication and the existing order contact
receives a decision link. Once SMTP accepts the message, dust-commerce clears
the raw token and retains only its SHA-256 fingerprint; accept changes the
owner in the same transaction as the decision. The public response is a
standalone five-field SQLx row type, so an internal model change cannot widen
the API by inheritance. The generated Flutter client receives only those
fields and Dio remains the sole owner of the authorization header.

The Flutter storefront completes the customer-facing request and decision
surfaces. The authenticated order list carries the source-shaped request form,
but its success state reports delivery to the current order contact rather than
disclosing that person's email. The public capability route reproduces the
pinned DTC illustration, copy, 40% desktop column and action styling. It is a
neutral page: accept and decline remain explicit POST actions, so mail-security
link scanners cannot transfer an order merely by opening the message.

### PostgreSQL timestamps stay native `TIMESTAMPTZ`

Medusa's PostgreSQL migrations use `timestamptz not null default now()`.
This project uses the same native `TIMESTAMPTZ` boundary. PostgreSQL defaults
create audit instants and triggers maintain `updated_at`; Dart contracts decode
them as UTC `DateTime` values. They are not generated columns, and application
clocks never write table audit timestamps.

## Not attempted

External fulfilment-provider integrations, labels and exchanges, external
payment integrations or saved payment methods, provider-driven taxes,
inventory locations, sales-channel management and product availability by
channel, product-type CRUD, password reset,
MFA, OAuth providers, API keys, admin RBAC, most admin catalogue mutations,
admin order/customer/operations APIs, workflow engine, plugin system,
notifications, external object/CDN storage, and a complete operational admin
dashboard.

Shipping is a small set of regional options with optional item-total rules,
promotions are one fixed or percentage code, and payment-provider availability
is configured per region while execution remains a manual state transition.
Authentication is email/password plus opaque sessions. Those
are tested vertical slices, not the corresponding Medusa modules in miniature.

## The honest summary

Across its 38 method/path operations, the domain modelling follows the same
core boundaries where they fit. On everything else, Medusa is a commerce
platform and this is a demonstration that Dust can generate one end of a wire,
decode it at the other, and statically validate SQL against a real schema.

If you want to sell something, use Medusa. If you want to see what a Dart
codebase looks like when the models on both sides of the network are generated
from one definition, read [the architecture notes](architecture/README.md).
