# Storefront design QA

## Source truth

- Medusa DTC source commit:
  `bd2441acc18359533758fbf4db5bc80129055d2e`.
- Verification route:
  `apps/storefront/src/app/[countryCode]/(main)/verify-account/page.tsx`.
- Verification component:
  `apps/storefront/src/modules/account/components/verify-account/index.tsx`.
- Registration state:
  `apps/storefront/src/modules/account/components/register/index.tsx`.
- Production preview: `https://next.medusajs.com/dk`.
- Prototype: Morrow at port `13001`, backed by the local API at port `3878`.

## Email-verification slice

The pinned source and Morrow use the same centered 384px content column, 32px
horizontal and 48px vertical page padding, uppercase semibold title, 16px
vertical rhythm, centered body copy, primary success action, and secondary
failure action. Morrow keeps its existing source-matched navigation and footer
around the route and replaces only the Medusa brand.

The local browser consumed a real database-backed capability, rendered the
success state, and navigated `Go to sign in` to `/account`. Reopening the
consumed link rendered the same invalid-or-expired state used for unknown and
expired capabilities. The capability never appeared in the public Dust state.

The live Medusa preview was captured successfully for the shared Store shell
earlier in the pass. When the verification route was requested for the final
same-state pair, the in-app browser proxy returned
`ERR_PROXY_CONNECTION_FAILED`. The component source remained available from
the pinned local clone, but source code is not a substitute for a same-state
rendered comparison.

## Product add-feedback slice

The pinned `CartDropdown` opens for five seconds when the cart item count
changes outside `/cart`; it does not show a separate toast. Morrow already
uses the same boundary in `CartPreview`, so the QA pass verified behavior
rather than adding duplicate product state.

Live local browser QA opened
`/products/t-shirt?v_id=var_tshirt_m_black`, added one selected `M / Black`
Essential T-Shirt, and observed the navigation count change to `Cart (1)`.
The desktop cart preview opened immediately with the thumbnail, variant,
quantity, USD 15.00 subtotal and `Go to cart`, then closed after the timed
window. Browser logs contained no warnings or errors. The separate
free-shipping nudge remained visible after the cart preview closed, which
matches its independent source slice.

Product-detail accessibility now follows the pinned gallery source's
`Product image N` alternative text. Live local AX QA on
`/products/t-shirt?v_id=var_tshirt_m_black` exposed `image Product image 1`
and `image Product image 2` while preserving the selected variant, price and
Add to cart controls.

The opt-in demo catalogue now includes `Split Raglan Tee`, a published
two-axis product with only `S / Black` and `M / White` variants. Focused
Storefront and server tests prove the product appears only in the development
demo layer, exposes both offered Size and Color values, resolves `S / Black`
to a real variant, and leaves `S / White` without a selected variant. Live
release-mode browser QA on an isolated seeded Store opened `S / Black`, then
selected `White`: `v_id` cleared, both selected option values stayed visible,
the price fell back to `From USD 23.25`, and the action disabled as
`Select variant`. Selecting `M` then re-enabled the real `M / White` variant
and restored `v_id=var_demo_21_m_white`. Browser logs contained no warnings or
errors.

## Authenticated account overview slice

The pinned account source uses the same `1024px` `small` breakpoint for the
account shell. At desktop width it renders a 240px left navigation, `Hello
{first_name}`, `Signed in as: {email}`, four-part profile completion, saved
address count, latest-five recent orders, and the shared `Got questions?`
footer. Under the breakpoint the overview content is hidden and the mobile
account navigation shows `Hello {first_name}`, `Profile`, `Addresses`,
`Orders`, and `Log out`.

Live local browser QA used a fresh database-backed customer,
`qa-account-1790395696@example.com`, with first name `Ada`, last name
`Lovelace`, and phone `+1 555 0100`. The desktop `/account` route rendered
the source-shaped left nav, `Hello Ada`, the signed-in email, `75% COMPLETED`,
`0 SAVED`, `No recent orders`, and the customer-service footer. The compact
`390 × 844` route rendered `Hello Ada`, the four mobile navigation rows and
the same footer, with no visible account overview metrics, matching the pinned
source's `hidden small:block` overview boundary. Browser logs contained no
warnings or errors.

## Checkout Review and order-confirmation slice

The current Medusa upstream `main` is `e3a237c9b8773cf35c899dabfe73afaebacbc8d5`.
Compared with the pinned `bd2441acc18359533758fbf4db5bc80129055d2e` target,
the checkout and order-completion source files are unchanged. Morrow's Review
step preserves the source hierarchy: completed address, delivery, and payment
summaries stay collapsed above the final legal acknowledgement and large
`Place order` action. The confirmation route preserves the source order:
thank-you heading, confirmation email, order date, interactive order number,
`Summary`, line items, totals, delivery, payment, `Need help?`, and footer.

Live local browser QA used a fresh seeded database and completed a guest
checkout for `Essential T-Shirt`, variant `M / Black`, with Standard shipping
and Manual Payment. The Review step rendered the selected address, shipping
method, manual payment details, USD 22.00 total, Morrow privacy-policy text and
`Place order`. Placing the order opened
`/order/id_Vtw4cMriy064SwGfrnCkfshZYbN9J7tamLLJO1ZMqbg/confirmed` with
order number `1`, the confirmation email `qa-checkout@example.com`, line item,
subtotal, shipping, taxes, total, delivery, payment, Contact and Returns &
Exchanges links, and `Powered by dust`. Browser logs contained no warnings or
errors.

Confirmation restoration now requires a completed, captured payment. A failed
capture may retain an order in memory so checkout can retry, but its order id
cannot render the confirmation route; the focused ViewModel regression asserts
that boundary before the retry succeeds.

The same pass exposed that the Address button persisted the address but could
remain on `?step=address` before a refresh. The route now follows the source
flow more directly: save the address, then move to Delivery; the Delivery page
already owns loading server-priced shipping options.

## Customer-return request slice

The pinned order-detail source keeps `Returns & Exchanges` in the compact
`Need help?` block. Morrow preserves that hierarchy and turns the link into an
authenticated, API-backed expansion rather than inventing a separate route.
Only completed or captured orders expose the control. The form freezes the
owned order items, requires at least one selected quantity, accepts an optional
note, prevents duplicate submission while pending, and reports only
display-safe server failures.

Authenticated browser QA created and captured order display id `1`, submitted
one Essential T-Shirt with the note `Customer return browser QA`, and received
return request `#1`. The database retained exactly one request and one item for
the signed-in customer. Reopening the form and requesting the already exhausted
quantity returned `These items can no longer be returned.` and did not create a
second row. This verifies the success, ownership, quantity and atomic rejection
boundaries against the real API; it does not prove an Admin decision workflow.

The slice passes all 120 non-widget storefront tests, Flutter analysis and all
47 generated Dust checks. Localization validation has zero errors and five
inherited warnings. The live desktop form and success/failure regions were
inspected without overflow or console-visible runtime failure. The pinned DTC
source provides the help link but no matching customer return form, so this is
a source-structured capability check rather than a same-state raster claim.

The follow-up reason slice exposes five active merchant reasons through the
public Store API and keeps the reason optional, matching Medusa's request
contract. Authenticated browser QA selected the completed order item, observed
the dedicated `OrderReturnReasonField`, and changed its generated ViewModel
state to `Changed my mind`. The selected label remained visible in the
expanded form. No helper method returns a Widget; loading, empty, failure and
loaded states belong to the dedicated widget class.

The remaining-quantity slice now returns Medusa's delivered, requested,
received and dismissed quantities on every Store order item. The return form
uses their returnable difference as its maximum and omits exhausted items.
Authenticated reload QA against order display id `1` showed `This order has no
items left to return.` with no checkbox, quantity, reason, note or submit
control. No additional return was submitted. The simplified lifecycle has now
been replaced: only quantities in active fulfillments with a real delivery
timestamp count as delivered or returnable.

## Store fulfillment-status slice

The pinned DTC `OrderDetails` component labels `order.fulfillment_status` as
`Order status`; it does not render Dust's separate business order status or a
tracking panel. Morrow now follows that exact source boundary. A standalone
Store enum keeps the customer contract separate from Admin, and direct SQLx
order projections derive partial and full fulfillment, shipment and delivery
from active fulfillment item quantities.

Live QA reused the fresh 59-migration return-history database. The authenticated
Admin API created and delivered the existing order's fulfillment, after which
the authenticated Store API returned `fulfillment_status: delivered` and one
delivered unit. The release-mode account order page rendered `Order status:
Delivered` at the default viewport and at `390 × 844`; the compact screenshot
showed no overflow and the browser console contained no warnings or errors.
The full 467-test server suite, 128 non-widget Store tests, both analyzers and
normal plus SQLx Dust checks pass.

## Collection/category refinement route slice

Collection and category routes now keep option-value refinements functional
instead of decorative. Toggling an option replaces the repeated
`optionValueIds` query, resets pagination to page one, preserves the route
handle and current sort, and clear-all removes the taxonomy route refinements.
Focused route-conversion and listing ViewModel tests cover the URL retention,
collection metadata, category hierarchy, filtering and missing-taxonomy states.

Accessibility QA on the live local Store route exposed that Flutter Web named
the price slider thumbs as raw integers. The price refinement now keeps the
native range control while exposing the formatted group value, e.g.
`Price USD 15.00 - USD 40.00`, after enabling Flutter semantics in the browser.

## Customer return-history slice

The pinned DTC order detail has no customer return-history component. Its
`Help` component renders `Contact` and `Returns & Exchanges`, both linked to
`/contact`. Morrow preserves the `Need help?` placement and adds its explicit
customer-owned history immediately below it. This is a secure Dust extension,
not a same-state Medusa raster-parity claim.

Live QA used a fresh database created by all 59 SQLx migrations. Supported
Store and Admin APIs created an authenticated customer, a completed and
captured order, and requested return `#1`; the generated history endpoint then
returned exactly one customer-owned row. No historical rows were patched by
hand.

The authenticated order-detail route rendered `Return history`, `Return #1`,
`Requested`, the localized request date, and `1 item(s)` at both the default
desktop viewport and `390 × 844`. A hard reload retained the secure session,
reloaded the generated history request, and rendered the same row. The browser
console contained no warnings or errors. The implementation passes all 127
non-widget storefront tests, Flutter analysis, and all 50 generated Dust
checks; no widget test was added.

## Store listing desktop alignment slice

The current Medusa DTC source at `913d4482641da21c9a219c92a5aa6b959af9bfd7`
places the Store title, search field, and product grid in the product column
beside the refinement sidebar. A fresh disposable PostgreSQL database with the
opt-in development seed and a release-mode Flutter web build were inspected at
the same `1686 × 772` desktop viewport. Dust now follows that composition: the
`All products` heading begins above the search row at the grid's left edge,
instead of spanning above the sidebar. Four-column card geometry and sidebar
placement matched the source capture; the corrected layout is committed as
`3665bfbf`.

## Admin return receipt slice

The pinned Admin source has no standalone Returns page. Order detail queries
requested returns and exposes `Receive return` from the Summary, so Morrow uses
that same hierarchy. The separate Admin contract and generated client list only
merchant-safe return fields through the shared Dio bearer, while the server
keeps both a route-level guard and authenticated handler extraction.

Live Admin QA against requested return `#1` rendered the Summary action and the
receipt dialog with intact, damaged and notification inputs. Cancel closed the
dialog without consuming the reusable fixture. Server tests submit the actual
command and prove that every item is validated before writes, partial and final
statuses are derived atomically, intact managed units are restored to stock,
and damaged or unmanaged units are not. Invalid mixed receipts roll back both
return progress and inventory.

The UI slice adds no widget test and no helper method returning `Widget`; each
subtree is a concrete widget class. All 82 non-widget Admin tests and all 386
server tests pass. Admin and server analyzers, normal Dust checks and SQLx Dust
checks are clean.

## Store search-result accessibility slice

The current Medusa DTC `SearchHit` is one product link with a decorative
thumbnail (`alt=""`) and visible product title. Morrow now exposes each drawer
hit as one semantic product button and excludes the thumbnail/title subtree from
duplicate semantics, keeping product discovery actionable without noisy image
announcements. Live local AX QA searched `tee`, exposed `Classic White Tee`,
`Heavyweight Black Tee` and `Split Raglan Tee` as buttons without thumbnail
noise, and selecting the first result opened `/products/classic-white-tee`.
The drawer chrome now follows the same current source geometry: bordered
16px/12px title row, bordered 16px search row, 8px result-list vertical
padding, 16px hit gap, no result dividers, and 56×64 rounded subtle
thumbnails without a border.
The failure state also follows the source `text-ui-fg-error` treatment instead
of rendering as muted helper copy.
Search hits use the same subtle hover surface as the source
`hover:bg-ui-bg-base-hover` link row.
The first non-empty debounced query enters the source `Searching…` state
immediately instead of leaving the start message visible until the timer fires.

## Live Medusa checkout comparison attempt

On 2026-11-04 the current Medusa preview rendered its live `/dk/store` with
eight products, and `/dk/products/espresso-cup` rendered the product detail.
Its `Add to cart` action stayed in `Loading…`; opening `/dk/cart` afterwards
still showed `Cart (0)`. The same disposable local stack added the seeded
T-shirt successfully and exposed `Cart (1)`. This is a source-runtime/API
availability failure, not a local storefront failure, so a same-state Review
and confirmation capture cannot be judged from this run. The pinned source
code and local checkout behavior remain the comparison baseline until the
preview cart endpoint accepts a guest add.

A follow-up check on the same date used the live `iPhone 16 Bundle` product.
Its source `Add to cart` button again stayed `Loading…` after the request, and
the header remained `Cart (0)`. Repeating the failure with a second product
confirms that the missing comparison state is a preview-runtime problem, not
an item-specific fixture failure.

The pinned DTC source was also run locally from commit
`913d4482641da21c9a219c92a5aa6b959af9bfd7` on 2026-11-04. Its backend ran on
`19090` against a disposable PostgreSQL database and its storefront on
`18000`; the repository seed rendered the four products. Selecting the
source's default `M / White` T-shirt variant and pressing `Add to cart`
completed successfully: the source header showed `Cart (1)` and the cart
preview showed the variant, quantity `1`, `€10.00`, and subtotal `€10.00`.
This is now the same-state source baseline for local pixel and flow
comparison; the public preview remains a separate broken fixture.

The same-day Dust run used the seeded `Essential T-Shirt`, `M / Black`,
Standard shipping and Manual Payment on `13001`/`3878`. The address save now
advances directly from `?step=address` to `?step=delivery` without disposing
the form, and the completed Review state shows the source-ordered address,
delivery, payment, totals, legal acknowledgement and `Place order` action.
The fix keeps an active checkout mounted while a cart mutation is loading;
the browser run reached Review after a hard reload with no console warnings or
errors. The local pinned source could not provide the matching flow in this
run because its no-JavaScript `/dk/cart/add` route throws
`cookies was called outside a request scope` under Next 16; its product/detail
render remains the visual source baseline.

## Open findings

- P2 — Capture the Dust and pinned-source confirmation states from the local
  same-state stack, then judge visible differences before declaring rendered
  parity; Dust Review is now captured, while the pinned source's cart route
  currently fails before checkout and the public preview remains unavailable.
- P2 — Repeat the verification success/failure capture against the live Medusa
  preview when its route is reachable, because its current cart failure is a
  separate runtime issue.
- P1 — Add external payment-provider refund adapters before claiming a complete
  production refund lifecycle; labels and exchanges remain separate.

## Result

The verification interaction, API boundary, local success/failure rendering,
reason selection, and navigation pass. Customer return creation and
server-side rejection pass against the live local stack. Exhausted quantities
are also disabled before submission. Customer return history passes desktop,
compact and reload browser QA as an explicit extension beneath the pinned
source's help block. Authenticated account overview and compact navigation
pass against the pinned source structure. Exact code-to-layout translation is
implemented where the pinned source owns a screen. Store order status and
return eligibility now use the real fulfillment lifecycle. Checkout Review,
manual placement and order confirmation now pass source comparison and live
local browser QA. Admin
requested-return receipt, intact inventory restoration and independent
manual-payment refunds pass, while broader storefront visual parity and
external refund-provider support are not claimed.

final result: partial
