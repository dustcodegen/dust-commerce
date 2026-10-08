# Medusa DTC storefront parity

The implementation target is the customer-facing storefront in
[medusajs/dtc-starter](https://github.com/medusajs/dtc-starter), pinned at
`15ef93da7d155ad990d8cc6db0296446fecbdfe6`. React and Next.js constructs are
translated into native Flutter and Dust patterns; the application talks only
to the dust-commerce API. Visual tokens are pinned to
`@medusajs/ui-preset@2.21.2`, the version used by that source revision.

The source pin was refreshed against upstream `main` on 2026-10-08. Current
Medusa DTC adds storefront search in the nav, `/store` page and right-side
drawer; this repository tracks that as a tested slice instead of treating the
older rendered-comparison pins as frozen truth.

Progress is tracked in [GitHub issue #29](https://github.com/y3l1n4ung/dust-commerce/issues/29)
and the `Medusa DTC storefront parity` milestone.

The functional Customer Service route is documented in
[customer-service-qa.md](customer-service-qa.md) as a Morrow extension because
the pinned DTC source has no equivalent route.

## Source-to-Dust map

| Medusa source | Flutter/Dust owner | Status |
| :--- | :--- | :--- |
| `layout/templates/nav` and `footer` | shared storefront shell | implemented in #19 with nav, menu, cart count, API-backed footer taxonomy, Morrow branding, and only `Powered by dust`; the compact menu and collection-footer composition passed rendered comparison, and the actionable brand now provides an explicit route label without Flutter web semantic warnings. Current-source search now opens a right-side drawer with Medusa's title, search field, 12-hit page, loading, empty and failure states; search hits expose source link semantics and `txt-medium` titles. |
| `layout/components/language-select` | storefront language preference | implemented in #19 with Default plus compiled Dust locales, localized names, real SVG flags, durable selection and startup restoration before routing. Source inspection and release-browser QA now verify selection closes the menu, preserves the complete product URL, survives a hard reload and clears back to Default; the live source advertises no locales, so a matched configured-selector raster remains unavailable. Product content localization is not claimed. |
| `layout/components/country-select` | shipping-country and selling-region switch | implemented in #24 with alphabetized active-region countries, real SVG flags, persisted selection, path-preserving navigation, atomic cart repricing, regional shipping reset and currency-aware catalogue reload. Source inspection and release-browser QA verify successful selection closes the menu, retains the cart and survives reload. The popup now copies Medusa's measured 320px width, 442px maximum height, 36px uppercase rows, 8px radius and placement 8px above its trigger; the configured country inventories still differ. |
| `home/components/hero` | home hero | implemented in #19 |
| `app/not-found` and `(main)/not-found` | unknown and missing-resource recovery | implemented with the source-exact hierarchy and copy, localized content, and a working frontpage link. Unknown routes retain the bare root boundary; missing products, collections, and categories preserve their URL and the Store navigation/footer. Root compact and main desktop comparisons plus compact local verification are recorded in `design-qa.md`. |
| `featured-products/product-rail` | featured product grid | implemented in #18 with source-ordered, API-backed collection rails; the compact two-column grid now uses natural-height cards and passed rendered comparison with the source's 24px column and 96px row gaps without overflow |
| `products/components/product-preview` | product card | implemented in #19; product cards use the source `thumbnail || images[0]` image fallback, Medusa UI card rest/hover shadows with the 150ms transition, horizontal sale-price treatment, `txt-compact-medium` typography and link semantics |
| `store/templates` | catalogue | partial in #18 and #19; current-source six-choice server sorting, relevance as the clean `/store` default, 12-item API paging, stable repeated option-value filtering, optional filter discovery, current-source `q` search, and Store sales-channel availability are implemented. Desktop grid and compact refinement geometry passed rendered source comparison. Compact page controls now match the pinned 18px/28.8px medium type and exact 12px visible gap, page 2 retains sort and repeated option queries, refinement changes reset to page 1, and search is retained in route state against the real API. Repeated option values now require every selected value in both page rows and counts, and channel-hidden products cannot be listed, read, added or quantity-updated. The public Medusa fixture has too few products to render its control, so rendered pagination comparison remains unavailable. |
| `products/templates` | product detail route | implemented in #22; source-ordered mobile and sticky desktop composition plus variant-specific image filtering, with desktop geometry, compact simple-product accordions, equivalent sold-out actions and option-sheet chrome passing rendered source comparison; compact selected state, desktop add-feedback and fixture-backed unavailable-combination rendering are browser-verified |
| `products/components/product-actions` | variant state and add to cart | implemented in #22, including source-selectable option values, exact-variant resolution, query-preserving `v_id`, unavailable combinations, variant-associated gallery reloads and a labelled, console-clean sticky-mobile option dialog |
| `products/components/related-products` | API-backed recommendations | implemented in #22 with loading, empty, failure and success states |
| `layout/components/cart-dropdown` | cart preview | implemented in #21 with hover, five-second post-add feedback, live removal, subtotal and empty state; preview item titles and prices follow the source `text-base-regular` rhythm, variant/quantity rows keep the source compact line rhythm, subtotal footer text follows source `text-small-regular`/`text-large-semi`, and the populated desktop preview passed rendered source comparison |
| `shipping/components/free-shipping-price-nudge` | global shipping progress popup | implemented in #21 with API-backed item-total rules, session dismissal, source actions, server-enforced eligibility, source-timed unlocked feedback and explicit popup widget ownership; local threshold interactions pass, while matched source rendering awaits a conditional source price |
| `cart/templates` and `layout/components/cart-mismatch-banner` | cart route and ownership recovery | implemented in #21, #26 and #28 with responsive source layout, empty state, line controls, explicit applied-promotion responses, authoritative totals, session-aware sign-in prompt, authenticated guest-cart transfer, global retry banner and a source-compatible checkout handoff that resumes the first incomplete address, delivery or payment step; the signed-out cart prompt now follows Medusa's `SignInPrompt` `txt-xlarge` heading and `txt-medium` body rhythm, the populated cart table header/title/variant text follows the source `txt-medium-plus`/`txt-medium` line boxes, the remove/quantity controls follow the source `DeleteButton`/`CartItemSelect` compact trash action and 56x40 grey rounded selector rhythm, unit and total line prices follow the source `LineItemUnitPrice`/`LineItemPrice` `text-base-regular` muted/subtle treatment, the summary totals use the source `CartTotals` `txt-medium` rows plus `txt-xlarge-plus` total value, and applied promotion rows follow the source `DiscountCode` `txt-medium`/`txt-small-plus` text rhythm with a rounded grey badge and compact remove action. Desktop empty/populated and open-promotion comparisons pass. A live compact anonymous populated-cart pair now verifies the shared hierarchy and local quantity/totals behavior. Morrow intentionally keeps all three compact columns visible instead of copying the source's horizontal overflow; persisted screenshot-artifact evidence remains unavailable. |
| `account/templates` | account shell and session | implemented in #20 and #26 with secure session, source-exact four-part overview completion, saved-address count, latest-five order links, profile name/phone/billing/password editing, API-backed address book, source-shaped navigation, order list, guarded order detail and customer-owned return requests; signed-out desktop and compact sign-in/registration passed rendered comparison. Authenticated desktop overview and compact account navigation now pass browser QA against the pinned source structure, while real support/policy destinations remain |
| `account/components/verify-account` | email verification capability | implemented with an explicit deployment switch, TLS SMTP delivery, hashed expiring single-use tokens, sign-in enforcement, resend rotation, a generated Dust client/state machine, and the source-shaped public route; local browser states pass and the blocked live-source comparison is recorded in `design-qa.md` |
| `checkout/templates` and `(checkout)/not-found` | checkout and payment | implemented in #28 and #20 with real address, region-scoped saved-address selection, server-retained address and payment progress, delivery, API-backed regional payment-provider discovery, manual payment, review and confirmation steps. A missing cart now preserves `/checkout` and renders the source 404 inside the checkout header and attribution shell, while the route-level guard still rejects a known empty cart. Guest address passes populated compact and desktop source comparisons, hard reloads retain Delivery and Review, and the local confirmation completed a release-mode purchase. Real desktop and compact delivery and payment choices expose mutually exclusive radio semantics, server-owned eligibility/provider selection, recalculated totals, progression and retained state. Address, Delivery, Payment and Review share the source's 48px large primary action. Review now passes source comparison and live local browser QA with completed address, delivery, payment, legal text and manual placement; live Medusa pixel capture remains separate. Pickup remains outside the Dust backend model and is not present in the current DTC seed. |
| `order/templates` | confirmation and order details | partial in #20, #26 and #28; confirmation, authenticated order list, source-shaped cards, guarded frozen order details, transfer request/decision UI, the secure order-transfer API/client and customer-owned return requests are implemented. Confirmation now matches the source `Need help?` block with both `Contact` and `Returns & Exchanges` links, while Morrow preserves the visible order-number prefill into its contact route. Guest confirmation now passes source comparison and live local browser QA for the source-ordered heading, email, order date, order number, summary, totals, delivery, payment, help links and footer. The transfer decision page passed desktop and compact rendered source comparison, with a deliberate 24px-inset full-width compact correction to Medusa's overflowing fixed 40% column. The transfer request form passes local desktop/compact, validation and safe-error checks. The return form is a real expansion of the source's `Returns & Exchanges` help link and passes authenticated browser success plus repeat-quantity rejection. Public merchant reason discovery, per-item optional selection and remaining quantities pass live browser QA. Customer-owned return history is implemented as a secure Dust extension below the pinned source's help block and passes desktop, compact and hard-reload browser QA. The source's `Order status` now renders the real Store fulfillment status; delivered item quantities and return eligibility come only from active delivered fulfillment records. Admin requested-return discovery, receipt, status progression, damaged tracking, intact managed-inventory restoration and independent manual-payment refunds are implemented; external refund providers, labels and exchanges remain. |
| `regions` store API | account, checkout and storefront country selection | implemented with explicit SQLx response allowlists; selectors use active backend regions rather than hard-coded countries |
| `payment-providers` store API | checkout payment choices | implemented with Medusa's `region_id` query contract, a direct SQLx response allowlist, stable ordering, and selection enforcement against enabled regional configuration |
| categories and collections routes | product organisation | implemented in #18 with real API metadata, filtering, hierarchy, sorting and paging; the compact collection grid and shared footer passed rendered comparison, while exact nested category paths wait on `dust#542` |

## Theme and selection map

These values come from the light tokens in
`@medusajs/ui-preset@2.21.2/src/theme/tokens/colors.ts`. Flutter uses semantic
names so components do not invent close-but-different greys.

| Medusa source token or class | Exact source value | Flutter owner |
| :--- | :--- | :--- |
| `bg-ui-bg-base` | `#FFFFFF` | `StoreColors.base` |
| `bg-ui-bg-subtle` | `#FAFAFA` | `StoreColors.subtle` |
| account `bg-gray-50` | `#F9FAFB` | `StoreColors.neutral50` |
| `border-ui-border-base` | `#E4E4E7` | `StoreColors.border` |
| `border-ui-border-interactive` | `#3B82F6` | `StoreColors.interactive` |
| `text-ui-fg-base` | `#18181B` | `StoreColors.foreground` |
| `text-ui-fg-subtle` | `#52525B` | `StoreColors.foregroundSubtle` |
| `text-ui-fg-muted` | `#71717A` | `StoreColors.foregroundMuted` |
| `rounded-rounded` | `8px` | product image and option radius |
| `small` breakpoint | `1024px` | product and cart desktop composition |
| `content-container` | `1440px`, `24px` inline padding | product content bounds |

`OptionSelect` is copied behaviorally rather than replaced by Material chips:
each value is an equal-width 40px rectangle on the subtle background, the
selected value changes only to the interactive border, and an unselected
hover receives the Medusa card-rest shadow treatment. Every value offered by an
option remains selectable, as in Medusa. A complete combination without an
exact variant clears only `v_id`, preserves unrelated query parameters and
keeps purchase disabled.

The pinned DTC query requests `*variants.images`; Dust's direct SQLx response
mirrors that shape. The public `StoreProductImage` contract contains only stable
id, URL and rank, and remains separate from the admin image response. Without a
valid `v_id`, or when the selected variant has no associated images, the
complete product gallery is rendered. Otherwise the gallery preserves product
order and keeps only image ids associated with that variant. Selecting Black
and White in the release-mode browser changes both `v_id` and the rendered
image set.

The store refinement sidebar also follows Medusa's `OptionsPicker`: filters
come from `/store/product-options`, every group starts expanded, selections use
stable value identifiers in repeated `optionValueIds` query keys, and changing
a selection removes the current page. Current Store option refinements start
directly with option groups, without a separate `Options` section label. Option
value chips include the source count treatment, e.g. `Black (3)`, and the
on-sale toggle carries the same muted count treatment. Option
discovery is intentionally non-fatal, while collection and category routes
retain incoming selections but hide the picker exactly as the source templates
do. Store refinement titles, counts, option chips, category and label checkbox
rows, and sort radio rows keep the source compact 12px/20px text rhythm; the
category and label checkbox controls also keep the source top offset.

Store search was browser-verified on 2026-09-26 against commit `d89bed8` using
a fresh seeded SQLite database and the live Store on `127.0.0.1:13001`. The nav
search opens the right-side drawer with the source title, close action,
placeholder, start state and clear control; `tee` returns Classic White Tee,
Heavyweight Black Tee and Split Raglan Tee; `zzzz` renders the explicit empty
state. Direct `/store?q=tee` restores the page search and filtered grid, and
editing it to `hoodie` updates the URL to `/store?q=hoodie` with only Oversized
Hoodie and Zip Hoodie visible.

The Medusa-only `ProductOnboardingCta` is intentionally excluded. It appears
only when a private admin-setup cookie is present and links to Medusa's local
admin onboarding flow; it is not a customer storefront capability or a valid
Morrow production destination.

The shared footer preserves the source structure and limits: the Morrow brand,
up to six API-backed root categories with direct children, up to six
collections, project-resource links, a current-year copyright line, and the
requested lowercase `Powered by dust` attribution. Category and collection
discovery fail independently so footer data cannot take down working page
content.

Medusa declares categories as a catch-all route so a full hierarchical handle
stays readable (`/categories/clothing/shirts`). Dust Flutter 0.1.4 currently
supports one segment per typed path parameter, so the generated route preserves
the same handle as `/categories/clothing%2Fshirts`. Exact parse-and-restore
support is tracked upstream in
[`dust#542`](https://github.com/y3l1n4ung/dust/issues/542); generated files are
not hand-edited around that limitation.

## Customer session boundary

Account responses and UI state are explicit field allowlists. They do not
inherit from database or domain models, so adding an internal field cannot
silently widen the storefront API. Bearer credentials are stored as one atomic
secure-storage value, attached only by Dio, and excluded from generated method
parameters and ViewModel state. The `/account/orders` route uses a typed Dust
guard and redirects a signed-out deep link to the shared `/account` sign-in
screen. The profile and address routes use the same guard. Address and order
state is cleared whenever the authenticated customer identity changes, and
in-flight responses from a previous identity are ignored. Checkout form state
is cleared on the same boundary, while authenticated customers can copy a
saved address into the editable form only when its country belongs to the
cart's active region. Order detail keeps its loaded order and failure as Dust
`Option` values, and a missing or foreign order receives the same unavailable
state so the UI does not disclose whether another customer's id exists.
The profile email row is a deliberate production adaptation: current Medusa
renders an email editor with a source TODO and fake success path, while Morrow
keeps registered sign-in email read-only until the backend has a verified
email-change flow with current-password confirmation and session-boundary
semantics.
Password rotation completes the TODO in the pinned Medusa profile source: it
requires the current secret, writes a fresh Argon2id PHC value with
compare-and-swap protection, atomically revokes every session, and signs the
Flutter customer out. The confirmation value never crosses the API boundary.
Email verification follows the pinned source without storing its capability in
Flutter state. A deployment must explicitly enable the requirement and provide
SMTP settings. Registration then stores only a SHA-256 token fingerprint in its
own one-shot reversible table, while the raw capability exists only in the
outbound adapter and confirmation request. Correct credentials rotate a lost
link but cannot create a bearer session until confirmation succeeds. The public
GET page is inert until Flutter deliberately POSTs the capability, and invalid,
expired, replaced, consumed, and unknown links share the same display state.
Accounts created before the switch have no verification row and remain usable.
The overview loads address and order capabilities independently, does not
report unknown data as zero, computes the same email/name/phone/default-billing
quarters as Medusa, and links at most the five newest server-ordered purchases.
Order-history absence and failure use Dust `Option` state rather than nullable
display strings.
Order ownership transfer follows Medusa's three-route request, accept and
decline shape. The target customer requests through a route-level bearer guard;
the existing order contact decides through a single-use emailed capability.
The public response is a standalone five-field allowlist mapped directly from
selected SQL columns, never an inherited order-transfer model. Only a SHA-256
fingerprint remains after SMTP accepts the message, accept moves ownership in
the same transaction as the decision, and invalid, expired and unknown
capabilities share the same not-found response. Delivery failures retain the
same capability for a bounded retry rather than silently reporting success.
The authenticated order-history page now includes the source transfer form and
delivery-aware feedback without revealing the current order contact's email.
The emailed capability opens a neutral public decision screen with the exact
MIT-licensed source illustration, copy, proportions and explicit accept or
decline controls. There are intentionally no GET routes that mutate transfer
state: automated email-link scanners may open the neutral page, but only a
deliberate button POST can accept or decline ownership.
Guest carts are claimed immediately after sign-in through a route-level bearer
guard and one conditional SQL update. The claim is idempotent for its owner,
hides foreign or terminal carts as not found, and remains race-safe when two
customers present the same capability. A failed transfer keeps the guest cart
recoverable behind the source-matched global retry banner; sign-out removes the
customer cart capability from secure local storage.

Conditional delivery prices follow the pinned Medusa `item_total` rule shape.
The storefront receives explicit rule allowlists with each shipping option and
uses the server-owned subtotal for the global free-shipping progress display.
The database enforces the same rule atomically when an option is selected, and
line mutations clear a chosen option in the same transaction if its rule stops
matching. An advertised shipping option and a selected shipping-method snapshot
remain separate contracts, so eligibility metadata does not enter frozen
orders.

Applied promotions use a standalone public allowlist rather than inheriting an
internal promotion model. The response exposes only id, code, type, value,
fixed-value currency and the current discount amount; validity windows, usage
limits and redemption counts remain server-only. The original reversible
`cart_promotions` migration creates this snapshot in one shot, including
database-generated UTC timestamps and an automatic `updated_at` trigger. Line
changes recalculate percentage amounts transactionally, and checkout freezes
the applied code and counts redemption only after the order write succeeds.
This vertical slice intentionally supports one promotion per cart; applying a
second code replaces the first until combination and exclusion policy exists.

Checkout addresses keep company and secondary street line as independent
optional values from Flutter input through the frozen order snapshot. The
original reversible `order_addresses` migration creates the company column in
one shot; it is not appended with an `ALTER TABLE`. A separate billing address
preserves intentional nulls instead of inheriting optional shipping values,
while an omitted billing address still reuses the shipping snapshot. The
source omits company from the collapsed checkout summary, so the Flutter
summary does the same without discarding the stored value.

The editable checkout step is also retained on the active cart instead of
living only in Flutter memory. The one-shot reversible `cart_addresses`
migration owns exactly that table, with a shipping/billing discriminator,
foreign-key cascade, database-generated UTC timestamps and an automatic
`updated_at` trigger. `PUT /store/carts/{id}/addresses` runs behind the shared
cart-access route guard, normalizes and validates nested input, rejects a
destination outside the cart region, and atomically stores contact, shipping
and optional billing values. Authenticated requests take their email from the
proven bearer identity attached by Dio. Cart reads expose only the public
address allowlist through direct typed SQLx row decoding, so a new checkout
view model restores the exact server-owned step after a browser reload.

Payment selection follows the pinned DTC source's discovery and durable
boundaries rather than remaining local widget state. Medusa fetches
`GET /store/payment-providers?region_id=…`, renders one radio card per returned
identifier, derives `selectedPaymentMethod` from the cart's pending payment
session, and initiates that session before navigating to Review. The matching
`region_payment_providers` migration owns enabled provider configuration for
one region, and the reversible `cart_payment_sessions` migration owns one
provider choice per cart. Each is a one-shot table migration with
database-generated UTC timestamps and an automatic `updated_at` trigger. The
provider-list query maps directly from SQLx into an explicit one-field public
response, while the guarded `POST /store/carts/{id}/payment-sessions` accepts
only a provider enabled for the cart region, upserts idempotently, and returns
the authoritative cart. No provider secret or internal adapter state is
disclosed. Flutter keeps the optional selection as `Option<String>`, hydrates
it from the cart, and renders only the API listing. A hard browser reload at
`?step=review` restores Review instead of falling back to Payment. Order
placement rechecks that the retained provider is still enabled, so disabling a
provider after selection cannot be bypassed with a direct checkout request. It
also requires the cart's selected shipping-method snapshot before reserving
stock or writing an order. A direct Review bypass receives `422` and leaves
both stock and orders unchanged.

The completed-order receipt now follows Medusa's full public payment boundary.
Its SQLx order query left-joins the existing `payment_collections` row and maps
provider id, authorised amount and database-generated creation time into a
standalone response allowlist; provider metadata and credentials stay private.
The shared Dust contract preserves that typed receipt through guest secure
storage and authenticated order reads. Confirmation rows use Medusa's 64px
thumbnail, `quantity x unit price` and line-total composition, delivery prices
are parenthesized, and payment shows its icon, provider title, charged amount
and localized time. Orders also expose a short monotonic `display_id` for
people while navigation and authorization retain the opaque order id. The
original one-shot `orders` migration owns that column; no appended `ALTER
TABLE` migration was introduced.

The account order-detail status follows the pinned DTC `OrderDetails`
component's `fulfillment_status`, not Dust's separate order lifecycle. Store
order list and detail queries derive not fulfilled, partial/full fulfillment,
shipment and delivery from active fulfillment-item quantities. Canceled and
soft-deleted fulfillments contribute neither status nor delivered units. This
same projection owns returnable quantity, so completing or capturing an order
cannot pretend that goods reached the customer. Store and Admin retain separate
contracts even though they derive the same merchant facts.

The storefront country control follows Medusa's source data flow rather than
being a display-only currency toggle. It derives an alphabetized country list
from `/store/regions`, renders ISO-backed SVG flags, persists the selected
country, and retains the active route. Moving an existing cart to a new region
is one transaction: every line must have a target-currency price before any
write occurs, line snapshots are repriced, the incompatible delivery quote is
cleared, and a percentage promotion is reapplied or removed. Catalogue and
product requests then reload in the selected region currency, so an
unavailable product or option combination is not advertised.

The storefront language control occupies the same menu position and uses the
same Default-first choice model as the pinned source. Its options come from
the locales compiled by Dust rather than an independently maintained widget
list, names change with the active locale, and language-to-region mappings use
real ISO-backed SVG flags. An explicit choice is persisted independently of
authentication and restored before the router is shown. The backend catalogue
has no localized content contract yet, so unlike Medusa the selection changes
the Flutter interface only; it does not add a misleading locale field to the
cart.

## Parity rule

A row becomes complete only when its primary interactions use the real API,
its loading, empty, failure and success states are covered, and the generated
Dust output, analyzer and tests pass. A static look-alike does not count.
The current rendered comparison gate is recorded in `design-qa.md`.
