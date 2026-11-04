# Storefront design QA

Source visual truth paths:

- Pinned source: `/private/tmp/dtc-starter.9KjRyK/source/apps/storefront/src/app/[countryCode]/(main)/order/[id]/transfer/[token]/page.tsx`
- Pinned compact transfer sources: `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/app/[countryCode]/(main)/order/[id]/transfer/[token]/page.tsx` and `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/order/components/{transfer-actions,transfer-image}/index.tsx` at `19e8a6fbefea5a385e9502409908bfbebbecf526`
- Rendered reference: `https://next.medusajs.com/dk/order/order_qa/transfer/demo-capability?qa=matched-final`
- Rendered compact transfer reference: `https://next.medusajs.com/dk/order/order_qa/transfer/demo-capability?qa=compact-20260914`
- Pinned transfer-request source: `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/account/components/transfer-request-form/index.tsx` at `19e8a6fbefea5a385e9502409908bfbebbecf526`
- Pinned catalogue source: `/private/tmp/dtc-starter.9KjRyK/source/apps/storefront/src/modules/store/templates/paginated-products.tsx`
- Pinned pagination source: `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/store/components/pagination/index.tsx`
- Rendered catalogue reference: `https://next.medusajs.com/dk/store?qa=store-grid-final`
- Pinned compact refinement sources: `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/store/components/refinement-list/{index.tsx,sort-products/index.tsx}`, `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/common/components/filter-radio-group/index.tsx`
- Pinned featured-rail source: `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/home/components/featured-products/product-rail/index.tsx`
- Rendered compact Store reference: `https://next.medusajs.com/dk/store?qa=compact-mobile-20260913`
- Rendered compact home reference: `https://next.medusajs.com/dk?qa=home-compact-20260913`
- Pinned product source: `/private/tmp/dtc-starter.9KjRyK/source/apps/storefront/src/modules/products/templates/index.tsx`
- Rendered product reference: `https://next.medusajs.com/dk/products/espresso-cup?v_id=variant_01KA906CNZ2951NNN2GDFV1QF8`
- Pinned empty-cart source: `/private/tmp/dtc-starter.9KjRyK/source/apps/storefront/src/modules/cart/components/empty-cart-message/index.tsx`
- Rendered empty-cart reference: `https://next.medusajs.com/dk/cart?qa=cart-empty-audit`
- Pinned populated-cart sources: `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/cart/templates/{index,items,summary}.tsx`, `components/{cart-item-select,item,sign-in-prompt}/index.tsx`, and `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/shipping/components/free-shipping-price-nudge/index.tsx` at `19e8a6fbefea5a385e9502409908bfbebbecf526`
- Rendered populated-cart reference: `https://next.medusajs.com/dk/cart?qa=populated-cart-source`
- Rendered cart-preview reference: `https://next.medusajs.com/dk/products/iphone-16-bundle?qa=cart-preview-source-ready`
- Pinned promotion source: `/private/tmp/dtc-starter.9KjRyK/source/apps/storefront/src/modules/checkout/components/discount-code/index.tsx`
- Rendered promotion reference: `https://next.medusajs.com/dk/cart?qa=promotion-shipping-source`
- Pinned public-account sources: `/private/tmp/dtc-starter.9KjRyK/source/apps/storefront/src/modules/account/templates/account-layout.tsx`, `login-template.tsx`, and `components/{login,register}/index.tsx`
- Rendered public-account reference: `https://next.medusajs.com/dk/account?qa=account-signed-out`
- Pinned checkout sources: `/private/tmp/dtc-starter.9KjRyK/source/apps/storefront/src/modules/checkout/components/{addresses,shipping,payment,review}/index.tsx`
- Rendered checkout reference: `https://next.medusajs.com/dk/checkout?step=delivery`

Implementation screenshot paths: in-app browser captures of the transfer route
`http://127.0.0.1:13001/order/order_qa/transfer/demo-capability?qa=compact-final-20260914`,
the authenticated request form at `http://127.0.0.1:13001/account/orders?qa=transfer-request-fresh-20260914`,
`http://127.0.0.1:13001/store?qa=store-grid-final`, and
`http://127.0.0.1:13001/products/shorts?qa=product-audit`, and
`http://127.0.0.1:13001/cart?qa=cart-after-restart`, and
`http://127.0.0.1:13001/cart?qa=populated-cart-restarted`, and
`http://127.0.0.1:13001/products/shorts?v_id=var_shorts_s`, and
`http://127.0.0.1:13001/account?qa=account-register-local`, and
`http://127.0.0.1:13001/cart`, and
`http://127.0.0.1:13001/checkout?step=review`, and
`http://127.0.0.1:13001/checkout?step=delivery`, and compact captures of
`http://127.0.0.1:13001/store?qa=compact-exact-20260913` and
`http://127.0.0.1:13001/?qa=home-exact-20260913`, plus the compact page-two
state at `http://127.0.0.1:13001/store?page=2&sortBy=price_desc&qa=pagination-final`.
The browser captures
are retained in the task evidence rather than exported into the repository.

Viewport: the matched desktop captures used the same in-app browser surface. The
reference raster was `1265 x 712`; the implementation raster was `1280 x 720`.
The reference's visible scrollbar produced the small raster-size difference.
The compact transfer pair used equal `390 x 844` CSS viewports at density 1.
The source's fixed two-fifths column produces narrow wrapping and a horizontal
scrollbar; the implementation intentionally expands to a 24px-inset native
column at this width. The authenticated transfer-request form was captured
locally at `1280 x 720` and `390 x 844`, both at density 1. A same-state
authenticated Medusa capture remains unavailable.
The promotion form comparison used the same `736 x 864` browser surface for
both storefronts. Guest checkout address and initial delivery comparisons also
used that same `736 x 864` surface. The desktop checkout comparison used an
equal `1280 x 720` CSS viewport; the final implementation capture came from an
isolated headless Chrome profile because the interactive Mac session locked.
The compact collection grid and footer pair used equal `390 x 844` CSS
viewports. The final menu interaction pass returned to the in-app browser after
it became available. The final compact Store and featured-rail comparisons used
equal `375 x 812` output rasters at device-pixel ratio 1. The reference tab was
requested at `390 x 844`; its visible scrollbar and browser capture crop
produced the `375 x 812` content raster, so the implementation was recaptured at
that exact output size before comparison. The pagination interaction pass used
a `375 x 812` CSS viewport at density 1.

Pixel dimensions, CSS size, and density normalization: both captures used the
in-app browser's default CSS viewport and density. Comparison normalized the
implementation by the reference-to-implementation ratio (`1265 / 1280`); no
finding was filed from the scrollbar or raster-size difference.

State: the public transfer page used the same `order_qa`, unused demo
capability, English locale, light theme and idle decision state. The catalogue
comparison used each backend's first unfiltered product page; product names and
images therefore differ, while the page structure and layout contract are
directly comparable. The product comparison likewise used the reference
Espresso Cup and Morrow's seeded Everyday Shorts, so option controls and copy
differ while column geometry remains comparable. The populated-cart pair used
one product line from each backend, and the cart-preview pair captured the
post-add panel while it was visibly open. Product names, prices and quantities
are merchant data differences; table and panel geometry are directly
comparable. The compact collection pair covered the two-column grid through the
shared footer; source and local taxonomy counts differ because they use separate
merchant data. The live side-menu comparison additionally covered the inset
blurred panel, source labels, close button, Escape dismissal and Store
navigation. The compact Store pair additionally covers the source refinement
inset, selected sort marker, label baselines and two-column grid. Morrow exposes
real Color and Size filters that the public Medusa fixture does not, so its
product heading begins lower by the height of intentional merchant data. Price
sorting and Black filtering were exercised through the generated route and real
API. Compact page 2 retained `price_desc`, returned the remaining eight
lower-priced products, disabled page 2, and kept the source's 12px visible gap
between its 18px/28.8px labels. Selecting Black from page 2 removed the page query
while retaining `price_desc` and the selected option-value id. The pinned
`@medusajs/ui-preset@2.20.1` token defines this type as 18px with a 28.8px line
box and weight 500. The live Medusa
fixture exposes fewer than thirteen products, so its pagination never renders;
this pass proves pinned source-code and local interaction parity but does not
claim a rendered pagination pair. Remaining global QA covers the product route at
compact width and in selected/out-of-stock states, authenticated
`/checkout` with a saved address available, authenticated `/account` with a
completed profile, saved addresses and recent orders,
`/account/orders/details/:id`, matched authenticated transfer-request rendering
and its delivery-sent/pending states, the profile password editor, the
guest-cart mismatch banner, compact cart, shipping interactions, the source promotion-success
state, and the global free-shipping popup. Promotion QA now covers the
source-matched open form plus
local success, recalculation, removal and safe-error states. The live source
returned a generic production Server Components error for the tested code, so
a rendered source success state is still unavailable. The empty-cart pair used
clean anonymous browser state with zero items on both storefronts. The account pair used the
signed-out sign-in screen, then exercised the in-place registration toggle and
Flutter validation without creating a customer. Local free-shipping QA used the
seeded server rule at `EUR 100`: below-target, unlocked, faded, restored and
session-dismissed states were captured. The live source cart exposed no
conditional zero-cost shipping rule, so a matched popup pair remains pending.
The guest checkout pair used equivalent complete addresses and one cart line.
The address form and initial delivery composition were compared together. The
local journey then reached Review through Standard delivery and Manual Payment
without placing an order. The live reference failed its Server Components
mutation when Standard delivery was selected, so it could not render payment
or review; those local states were checked against the pinned source structure
rather than claimed as a successful live pair. Desktop QA repeated the address
step at `1280 x 720`, then advanced to Delivery and hard-reloaded the route. The
collapsed shipping/contact summary and selected checkout step survived from
the server cart. A local authenticated account also rendered the region-scoped
saved-address selector; the public reference was not mutated to create an
account, so authenticated head-to-head evidence remains open.

**Findings**

- [P1] Remaining route groups still lack rendered comparison
  Location: compact product layout; checkout authenticated,
  payment, review and confirmation states; account and order
  views; transfer-request states; mismatch banner; and the global shipping
  popup.
  Evidence: matched comparisons now cover the transfer decision, desktop
  catalogue, compact Store refinements and featured rail, compact collection
  grid/footer/menu, desktop product structure, empty and populated desktop cart,
  compact populated guest cart, open cart preview, signed-out account, and the
  open promotion form. The
  remaining states listed above do not yet have matched captures.
  Impact: their typography, responsive spacing, imagery and interaction states
  remain visually unverified.
  Fix: capture both sites at matching desktop and mobile viewports, combine
  each pair, and run the comparison loop.

- Account content destinations are now actionable
  Location: signed-out account support and registration terms.
  Evidence: Customer Service, Privacy and Terms routes are public; the
  registration consent uses underlined actions that navigate to the local
  `/privacy` and `/terms` equivalents of Medusa's content links.
  Remaining limitation: a fresh matched-raster capture of the registration
  links is still pending, so this closes the functional gap, not the visual QA.

**Required fidelity surfaces**

- Fonts and typography: the transfer hierarchy, catalogue title/card copy,
  compact sort labels, 18px medium pagination with a 28.8px line box, product
  information stack, empty and populated-cart
  hierarchy, cart preview, and public account forms passed; other routes remain
  pending.
- Spacing and layout rhythm: the transfer's centered column and the catalogue's
  sidebar, 24px gutters, four-column medium grid, 32px row gap and card rhythm
  passed after scrollbar normalization. The compact collection uses the
  source's two-column flow, natural card heights and two-column taxonomy footer;
  its inset menu follows the source width, blur, radius and 24px content inset.
  Compact Store refinements add the source's second 24px inset, use the selected
  row's negative 23px marker offset, and retain a 24px two-column product gap.
  Compact featured rails use natural card height with 24px column and 96px row
  gaps, matching the source without a constrained-card overflow. Compact
  pagination removes Material's implicit button padding so its rendered labels
  have the source's exact 12px visible gap and 48px grid-to-control margin.
  Product detail now matches the source
  24px inset, 300px side columns, 64px gallery gutters and 192px sticky offset.
  Empty cart matches the source's combined 32px content inset, centered vertical
  composition and footer position within three rendered pixels. Public account
  sign-in and registration match the source's 384px form, 240px desktop rail,
  44px inputs, 40px primary action, divider and help-block placement. The
  populated cart matches the two-column grid, 160px gap, table tracks, 96px
  thumbnail, 40px quantity control and source omission of the final-row divider.
  The 420px preview aligns to the header's 24px right gutter and reserves the
  source's 122px image track plus 16px content gap.
- Colors and visual tokens: transfer foreground, zinc-600 copy, gray-200
  borders, exact black primary actions, the cart's neutral quantity pill,
  compact Store muted/selected text including the active pagination number,
  red/rose errors and emerald success are
  source-mapped; other rendered routes remain pending.
- Image quality and asset fidelity: the transfer uses the exact source SVG. The
  catalogue uses merchant images from each backend with the source's `9:16`
  card ratio, while featured rails use each backend's real merchant images at
  the source card ratio and natural height. The cart and preview use each
  backend's real product thumbnail at the source's 96px square size;
  cross-backend product photography is intentionally not compared.
- Copy and content: the transfer heading, paragraphs and actions now match the
  source exactly. Empty-cart copy and its interactive link also match. Morrow
  account membership copy, required markers and toggle punctuation match the
  source structure. The populated cart and preview retain the source labels and
  remove the invented success toast because the timed preview is the source's
  add feedback. The promotion form retains the source's blank input, compact
  row, applied heading, code badge, visible value and post-success open state.
  Compact Store uses the source's `Sort by`, arrival and price labels. Its extra
  Color and Size copy reflects real Morrow option data absent from the public
  reference fixture. Pagination uses only the source number and ellipsis copy;
  the two-page development catalogue therefore renders `1 2` without invented
  next/previous labels.
  Morrow branding, privacy-safe omission of the owner email, and
  the temporarily non-actionable content-link text are intentional product
  differences. Guest checkout matches the source field order, required
  markers, billing toggle, desktop summary hierarchy, delivery labels and
  payment/review hierarchy. The
  local delivery prompt intentionally corrects the source typo from "you
  order" to "your order"; other route copy remains pending.

**Full-view comparison evidence**

The source and implementation transfer pages, then the two catalogue pages,
were captured from the same in-app browser tab and emitted as matched pairs.
The transfer composition and controls align. The catalogue title, sidebar,
four-column grid, source aspect ratios and card spacing align after correction.
The equal-viewport compact transfer pair confirms the exact illustration, copy,
divider sequence and action order. The implementation's full-width 24px-inset
column is an intentional responsive correction to the source's fixed 40%
column, which wraps excessively and exposes a horizontal scrollbar at 390px.
A fresh implementation tab rendered without console warnings.
The implementation-only authenticated request-form pass confirms the source
order, two-column desktop composition, stacked compact composition, empty-order
context, required-field validation and display-safe unavailable-mail feedback.
A fresh compact tab produced no new browser warnings or errors. The source code
matches the visible hierarchy, but no authenticated Medusa reference capture
was available, so this is not a rendered parity claim.
The equal-raster compact Store pair aligns the second 24px refinement inset,
selected dot, all three sort-label baselines and two-column catalogue. The
paired home rail captures align natural card heights and the source's 96px
compact row rhythm. Product and collection names remain expected merchant-data
differences.
The compact page-two capture is implementation-only because the public source
fixture never exceeds one page. It confirms the source-authored type, spacing,
selected state and footer rhythm, while the live interaction proves page and
refinement navigation. No rendered head-to-head pagination claim is made.
The equal-width compact collection pair confirms the two-column grid, wrapped
card metadata and responsive footer. A final in-app browser pass confirms the
source-shaped menu, both close paths and navigation to `/store`.
The product detail pair confirms the source column geometry and information
stack; product content and action controls differ with the two seed products.
The compact product pass exercised the pinned `OptionSelect`, `ProductActions`
and `MobileActions` contracts at `390 x 844`. Morrow kept all six offered option
buttons enabled, changed `v_id` while preserving the unrelated `qa` query, and
rendered its deterministic sold-out product with a disabled `Out of stock`
action. The compact option route now announces `Select options`, exposes a
labelled Close control and opens without browser console warnings. The live
Medusa catalog has no sparse option combination. A later equal-raster pair now
proves the compact page rhythm, gallery, sticky purchase chrome, option-sheet
chrome and related-card grid. Populated option-body density and the
unavailable-combination rendered pair remain blocked rather than inferred from
different merchant states.
The implementation-only compact cart pass used a `390 x 844` CSS viewport with
one anonymous line. Changing quantity from one to two updated the cart count,
line total, subtotal, tax and total from the server, and checkout opened
`/checkout?step=address`. The pinned source confirms the same quantity and
first-incomplete-step contracts. A fresh live Medusa add-to-cart attempt ended
in a production Server Components error, so no same-state compact pair is
claimed; browser removal remains open while the real API/ViewModel test covers
the mutation and resulting empty cart.
The empty-cart pair confirms the source content inset, copy, vertical placement,
blue diagonal-arrow link and footer divider. The signed-out account pairs
confirm the sign-in and registration compositions, exact control rhythm,
password visibility affordance, toggle behavior, readable validation and shared
support layout. The populated-cart pair confirms matching heading rhythm, table
tracks, line controls, totals and checkout action. The post-add product pair
confirms the cart preview's panel placement, item layout, subtotal and 48px
primary action while the panel remains open for its five-second feedback window.
The promotion pair confirms the compact blank input and secondary action at an
identical viewport. Local interaction captures additionally prove apply,
percentage disclosure, recalculation, removal and safe failure rendering.
The checkout pair confirms the compact address geometry, country placeholder,
billing toggle, Continue action, step dividers and initial delivery state. The
local server-backed journey additionally proves Standard delivery, the
API-listed Manual Payment choice and Review with authoritative totals. It
deliberately stopped before Place order. Manual Payment is retained on the
server-owned cart; a hard reload at `/checkout?step=review` restored the same
URL, collapsed payment summary and active Review action. A later exact-source
pass loaded Medusa's Payment route directly and compared the same selected
Manual Payment state beside Morrow at the same browser surface. The radio card,
interactive border, icon, spacing and black action treatment align. The source
still lacked a completed address and delivery state, so no whole-page Review
match is asserted. After adding the server-side delivery guard, the valid local
path returned from Payment to Review with the same collapsed summaries and
`Place order` action; no local UI changed. A fresh Medusa Review capture still
lacked completed shipping state, so this regression pass does not add a
same-state whole-page parity claim. A subsequent fresh local release-mode
purchase reached the confirmation route and retained it through reload. Source
inspection then corrected the receipt to its 64px table rows, quantity/unit and
line price stack, short display number, parenthesized delivery cost, and
provider amount/time payment details. The matching live Medusa cart was reset,
but its Espresso Cup add mutation remained indefinitely in `Loading...`, so a
same-state confirmation screenshot could not be produced and no visual match
is asserted. The desktop pass confirms the
complete back label, 24px semibold summary heading, source-spaced dividers, right-aligned
quantity/unit price, and final totals rule. A browser-only CORS failure on the
new address PUT was found and fixed before the successful Delivery transition;
hard reload then reproduced the same collapsed address state.

**Focused region comparison evidence**

No focused crop was necessary for the transfer, empty-cart, public-account or
populated-cart pages because the full-view captures kept their copy and actions
clearly readable. The open 420px cart panels were emitted as matched full-page
pairs at native density; their type, thumbnail, subtotal and action remained
large enough for focused inspection without a lossy crop. Compact collection
cards, footer columns and the side menu were readable in their full-page
captures. The selected Manual Payment control was emitted in a same-surface
pair after both implementations loaded their provider list. Store filters,
including the selected marker and all labels, remained readable in the paired
compact full view, so a lossy crop was unnecessary. Authenticated account forms
and remaining checkout controls still require focused captures.
Pagination labels were measured directly at density 1 after the final token
change: each single digit is `10.10 x 29` rendered CSS pixels, the rounded form
of the 28.8px line box, with `12.01px` of clear space. A separate lossy crop is
unnecessary. The missing rendered source control remains the comparison limit.

**Comparison history**

- Initial transfer comparison found P2 copy and typography drift: the intro was
  paraphrased, the primary action used zinc instead of source black, and the
  smaller body changed line wrapping. The copy, token and body size were fixed.
- The second transfer comparison found the content stack ten pixels too low.
  The image-to-heading and heading-to-body gaps were corrected.
- The final combined comparison found no actionable P0, P1 or P2 transfer-page
  difference. Residual two-to-three-pixel vertical variation is P3 and follows
  browser text rendering; the raster-width difference is the source scrollbar,
  not layout drift.
- The compact transfer comparison retained source content and action fidelity
  while classifying the implementation's 24px-inset full-width column as an
  acceptable native adaptation. The source's fixed 40% column is not copied at
  390px because it creates severe wrapping and a horizontal scrollbar.
- The authenticated request-form pass verified local desktop and compact idle
  states, required-field validation and safe unavailable-mail feedback against
  the real API. The public reference had no reusable authenticated account, so
  delivery success/pending and a same-state visual pair remain blocked.
- The first compact collection pass exposed bottom-overflow stripes on wrapped
  product names and a one-column footer caused by fixed card heights and a
  desktop-sized column gap. Natural-height cards and the source compact footer
  spacing removed both defects. The side-menu pass then replaced the default
  opaque drawer with the source's inset translucent panel, restored the `Store`
  label, matched its responsive minimum width, and verified button and Escape
  dismissal plus Store navigation in the live browser.
- The initial catalogue comparison exposed a P1 three-column grid and `11:14`
  cards caused by measuring the post-sidebar box. The implementation now uses
  Medusa's viewport breakpoints, four columns at 1280px, `9:16` catalogue cards,
  `11:14` featured cards and source-shaped title/price visibility. The final
  combined comparison found no remaining P0, P1 or P2 desktop-grid mismatch.
- The compact pagination pass replaced default Material button constraints with
  dedicated page-button widgets and typed page/ellipsis entries. Source-range
  unit tests cover all, leading, middle and trailing sequences. Browser QA then
  proved page-two data, retained sort, current-page disabling and refinement
  reset with zero observed console errors. Rendered source comparison remains
  unavailable because Medusa's public catalogue exposes only one page.
- The first compact Store comparison exposed P2 drift: refinements missed the
  source's extra 24px left inset, and every sort row reserved selected-icon
  space. Mapping `pl-6` and the selected-only `ml-[-23px]` behavior aligns the
  title, dot and all three label baselines in the final equal-raster pair. Live
  QA changed the route to `sortBy=price_desc`, selected Black through
  `optionValueIds=optval_color_black`, returned only the matching product and
  logged no browser errors.
- Compact navigation briefly exposed a latent P2 featured-card overflow from a
  fixed grid extent. Replacing that extent with the source's natural-height
  grid behavior preserves 24px horizontal and 96px vertical gaps. The final
  paired rail capture matches the source rhythm and a fresh local tab logs no
  errors.
- The initial product comparison exposed P2 column/gutter drift and a missing
  source collection link. The final pair aligns the source 24px page inset,
  300px side columns, 64px gallery gutters, 192px sticky content position and
  30px/40px title treatment. Cross-backend product copy, imagery, and variant
  controls remain data differences rather than visual findings.
- A clean preview restart proved the initial blank empty-cart capture was stale
  preview state rather than a product defect. The first valid comparison exposed
  a P2 missing 8px inner inset and a gray horizontal-arrow button in place of
  Medusa's blue InteractiveLink. The final pair uses the 32px combined inset and
  reusable blue diagonal-arrow link with no remaining P0, P1 or P2 mismatch.
- The first settled account comparison exposed a P1 full-width, top-aligned form
  with no source AccountSupport section. The source shell, empty 240px signed-out
  rail, centered 384px form, typography and support divider were translated.
  A browser validation pass rejected a tightly constrained input experiment
  because it compressed error borders; the final dense 44px controls retain
  readable expanding errors. The sign-in/register pair has no remaining P0 or
  P1 mismatch. The later consent-link slice replaced the former dead policy
  text with actionable Privacy and Terms destinations; only a fresh visual
  capture remains.
- The initial populated-cart comparison exposed P2 regular-weight headings, an
  Item label over the product-title track, a compressed quantity column, square
  quantity control, extra final-row divider and 14px actions. The final pair
  matches the source heading weights, table tracks, neutral pill and 16px/40px
  controls with no remaining P0, P1 or P2 desktop-cart mismatch.
- The compact populated-cart implementation keeps the source's 24px inset,
  mobile Item/Quantity/Total columns and stacked Summary. Browser interaction
  changed quantity one to two and recomputed `USD 30.00` subtotal, `USD 3.00`
  tax and `USD 33.00` total before entering the address step. The live source
  mutation failed, so this is interaction evidence rather than a visual pass.
- The initial cart-preview comparison exposed P2 viewport-edge anchoring,
  compressed thumbnail-to-copy spacing, a 40px instead of 48px primary action,
  an invented success toast and premature dismissal when the pointer was away.
  The final post-add pair aligns the panel to the header gutter, matches the
  source item grid and action size, and preserves the five-second feedback
  window. Cross-backend item content is an expected data difference.
- The initial promotion comparison exposed a P2 full-width local input, visible
  placeholder, taller field, hidden promotion value and form dismissal after
  success. The final open-form pair matches the source's compact 40px blank
  field and action. Local browser QA applied `WELCOME10`, displayed
  `WELCOME10 (10%)`, recalculated `EUR 1.50` to `EUR 3.00` when quantity changed,
  removed it, and rendered an invalid-code error. Source success comparison
  remains unavailable because the live reference returns a generic production
  Server Components error for the submitted code.
- Source inspection found that the free-shipping popup holds its green unlocked
  state for one second and then fades for 500ms; the local popup previously
  disappeared immediately. Browser QA now proves the server-owned `EUR 100`
  boundary, remaining amount, unlocked hold/fade, reappearance below the
  threshold and cart-session dismissal. The same pass fixed the quantity `10`
  wrapping inside its source-sized 56px control. A matched rendered popup pair
  still needs a source cart with a conditional free-shipping price.
- The initial checkout comparison exposed a P2 preselected country, combined
  company/apartment value, Material-scale fields, oversized gaps, sticky local
  attribution and incorrect step spacing. The corrected address state matches
  the source's field order, blank country placeholder, 44px controls, 14px
  rhythm, billing toggle and in-flow `Powered by dust` placement at `736 x
  864`. Company and apartment now remain independent through the real API and
  frozen order snapshot. Standard delivery and Manual Payment reach Review
  locally; the source delivery mutation fails before those live states.
- The first desktop checkout retry exposed a production CORS omission: direct
  tests passed, but the browser could not preflight the new cart-address PUT.
  The explicit storefront policy now includes PUT with preflight coverage. The
  corrected `1280 x 720` render also fixes the truncated back label, oversized
  cart heading, excess divider spacing, and non-source line-price layout. A
  hard reload at Delivery preserves the collapsed server-owned address step.
- Source inspection then exposed a functional reload gap that screenshots did
  not: the pinned Payment component derives its selected provider from the
  cart's pending payment session, while Flutter held `manual` only in memory.
  The generated client now selects an allowlisted server session through the
  guarded cart route, checkout refuses an unselected provider, and a settled
  release-mode browser pass proves Review survives a hard reload with the
  source-exact `Place order` action. A same-state rendered pair remains blocked
  by the live reference's failing Standard-delivery mutation.
- The checkout transaction now rejects a missing shipping-method snapshot
  before stock reservation or order creation. Targeted and full server/client
  suites prove the bypass returns `422` without changing stock or order count;
  the normal release-mode browser path still reaches Review. Because this is a
  backend guard with no UI delta and the live source remains in an incomplete
  shipping state, no new visual parity result is claimed.
- A fresh database and release-mode browser purchase proved the complete local
  cart → address → delivery → payment → review → confirmation path, including
  a database-owned display number and an API-backed provider amount/time
  receipt that survives route reload. The final top and detail captures were
  inspected at `1280 x 720`. Medusa's source code supplied the exact component
  contract, but its live add-to-cart mutation stalled after the previous cart
  was cleared, so same-state confirmation comparison remains pending.

**Implementation checklist**

- Obtain a non-destructive authenticated Medusa request-form capture for the
  matched desktop and compact pair. Local idle, required-field and safe-error
  states pass; rendered delivery-sent and delivery-pending states remain.
- Capture compact catalogue page 2 and verify paging retains active sort and
  option queries; compact sorting, option filtering, collection, shared-footer
  and side-menu QA now pass.
- Capture a matched compact product pair for unavailable-combination and
  add-to-cart feedback states; page layout, selected state, option-sheet chrome,
  query preservation and sold-out behavior are browser-verified.
- Retry the matched compact populated-cart capture when the live source can add
  a line; local quantity, authoritative totals and address-step handoff pass,
  while browser line removal and a same-state shipping popup remain open.
- Capture authenticated checkout against a non-destructive reference account;
  retry the payment/review pair when the reference delivery
  mutation works, then capture confirmation without placing an unintended
  reference order.
- Capture a source promotion success state when the reference has a valid code,
  then compare it with the verified local applied and removal states.
- Capture signed-out account at compact width after the real customer-service,
  privacy-policy and terms routes are available under #20.
- Capture the remaining route and interaction states listed above.
- Compare each source/implementation pair together and fix every P0/P1/P2
  difference before changing the global result.

**Follow-up polish**

- Reassess the transfer page's residual P3 text-rendering variation only after
  a true equal-raster capture is available.

## Admin product media slice

Source: Medusa commit \`bda24b9725ac697ec5e8f706b503013e20babf12\`,
\`product-create-details-media-section.tsx\`, and
\`upload-media-form-item.tsx\`. Prototype: Morrow Admin on port \`13002\`
with API port \`3878\`.

Medusa reference and Morrow implementation were captured in the same in-app
browser at \`505 x 583\` and combined before review. The official 16:9 reference
is letterboxed at this viewport, so structural parity is verified; pixel parity
is not claimed.

- Pass: Media follows Description and precedes Variants.
- Pass: optional label, upload action, supported formats, size policy, ordered
  rows, thumbnail action and delete action follow pinned source.
- Pass: upload, cancel cleanup, attachment, storefront delivery and attached-file
  deletion guard are real API behavior, not visual placeholders.
- Open P1: post-create media mutation remains.
- Open P1: multi-node object storage and abandoned-stage cleanup remain.
- Open P2: obtain an unletterboxed source capture for pixel-diff QA.

Admin product media result: passed

## Admin product variant-detail slice

Source visual truth: Medusa `2.20.1` at pinned commit
`bda24b9725ac697ec5e8f706b503013e20babf12`, specifically
`packages/admin/dashboard/src/routes/product-variants/product-variant-edit/`
and `product-edit-variant-form.tsx`. The source was run locally on port `19000`
against its isolated demo catalogue.

Implementation: Morrow Admin on port `13002`, backed by the Dust API on port
`3878` and a fresh migrated QA database. Both drawers were captured at equal
`1280 x 720` CSS viewports and combined into one `2560 x 720` comparison at
`/private/tmp/dust-commerce-admin-variant-qa-20260907/variant-edit-comparison-final.png`.

State: light theme, authenticated product detail and the `M / Black` variant
drawer. Source and implementation use different merchant SKU prefixes; this is
a catalogue-data difference, not layout drift.

**Findings**

- No actionable P0, P1 or P2 variant-drawer difference remains in the combined
  first-fold comparison or the matched inventory and attribute inspections.
- Broader Admin and storefront parity findings remain open, so the repository's
  global QA result remains blocked.

**Required fidelity surfaces**

- Fonts and typography: heading, label, optional-marker and hint hierarchy pass.
- Spacing and layout rhythm: 560px inset drawer, sticky header/footer, field
  cadence, dividers and scroll behavior pass.
- Colors and visual tokens: neutral inputs, overlay, borders, black actions and
  compact blue inventory switch pass.
- Image quality and asset fidelity: no product imagery belongs inside this
  drawer; surrounding page imagery still needs the matched full-view capture.
- Copy and content: Material, ordered options, SKU/EAN/UPC/Barcode, both exact
  inventory hints and all seven attribute controls match the source hierarchy.

**Full-view comparison evidence**

The equal-size full views were emitted as one comparison. Drawer edges, header,
first four fields, first divider, inventory heading and footer align without an
actionable mismatch.

**Focused region comparison evidence**

No crop was required. Scrolling each live drawer exposed the policies and full
attribute section at readable native density.

**Comparison history**

- The first comparison found a flush 520px drawer, reversed option order,
  missing fields, boxed policies and mismatched copy.
- The final implementation uses the source's 560px inset geometry, database
  option rank, complete generated contract, compact policies and searchable
  250-country selector.
- Browser QA searched for Denmark, saved the variant, observed `Variant
  updated.`, reopened the drawer and confirmed the server-backed value.

**Implementation checklist**

- Keep the combined evidence with this task; temporary QA rasters are not
  committed to the product repository.
- Continue with the next feature slice only after this stacked branch is
  reviewed.

Variant-detail slice result: passed

## Admin product-option edit slice

Source visual truth: live Medusa `2.20.1` at pinned commit
`bda24b9725ac697ec5e8f706b503013e20babf12`, specifically the product-option
detail action and
`packages/admin/dashboard/src/routes/product-options/product-option-edit/`.
The source and Morrow drawers were captured in the in-app browser at equal
`1280 x 720` viewports, then combined at
`/private/tmp/dust-commerce-admin-option-qa-20260907/option-editor-comparison-final.png`.

State: authenticated dark theme with one Size option and four ranked values.
The isolated catalogues use different value ranks, so the source displays
`L, M, S, XL` while Morrow displays its database order `S, M, L, XL`.

**Findings**

- No actionable P0, P1 or P2 drawer difference remains after matching the
  560px inset surface, field fill, chip geometry, 16px body padding, rank rows,
  icon assets and sticky footer.
- The wider Medusa navigation path still goes through Product Options list and
  detail pages; Morrow currently opens this editor directly from product
  detail. That route-level parity remains open in Admin QA.

**Functional evidence**

- Browser QA renamed Size to Fit, added an unused XXL value, saved, and read
  both changes back from refreshed Admin detail.
- A clean storefront session rendered `Select Fit` and disabled XXL because no
  variant selects it. A second Admin save restored Size and removed XXL, and a
  clean storefront session rendered the restored canonical state.
- Nineteen non-widget Admin tests pass, including refreshed-state, selected
  value conflict and sibling-title conflict behavior.

Product-option edit slice result: passed

## Admin product query-controls slice

Source visual truth: live Medusa Admin at pinned commit
`bda24b9725ac697ec5e8f706b503013e20babf12`. Medusa and Morrow were captured
at equal `1280 x 720` light-theme viewports for the neutral Products table and
open Add filter menu. Exact combined evidence remains in the task at
`/private/tmp/medusa-morrow-product-list-final-comparison.png` and
`/private/tmp/medusa-morrow-product-filter-menu-final-comparison.png`.

**Findings**

- No actionable P0, P1 or P2 difference remains in this slice after matching
  the content-sized card, 48px rows, equal columns, 64px pagination, status
  marker, source copy, filter order and 300px menu geometry.
- Sales Channel is intentionally absent because Morrow has no corresponding
  domain or API. The Material submenu appears before its filter chip, while
  Medusa materializes the chip first; this is remaining P3 interaction polish.

**Functional evidence**

- Type discovery exposed the four database values. Selecting Shirt reduced the
  live table to Essential T-Shirt and exposed the accessible action
  `Remove Type: Shirt filter`; Clear all restored all four rows.
- A clean Admin load produced no browser warnings or errors. No widget tests
  were added.

Product query-controls slice result: passed

## Admin product shipping-profile slice

Source visual truth path: Medusa's official Shipping Configuration Section
raster at
`https://res.cloudinary.com/dza7lstvk/image/upload/fl_lossy/f_auto/r_16/ar_16:9,c_pad/v1/User%20Guide/Screenshot_2025-02-17_at_6.38.17_PM_ko3a9x.png`
and pinned source commit `bda24b9725ac697ec5e8f706b503013e20babf12`,
specifically `product-shipping-profile-section.tsx`, `sidebar-link.tsx`,
`product-shipping-profile.tsx`, `product-shipping-profile-form.tsx`, and the
English `products.shippingProfile` translations.

Implementation screenshot path: in-app Browser captures of the authenticated
Morrow product detail and Shipping Configuration drawer at
`http://127.0.0.1:13002/`. The captures are retained in the task evidence rather
than exported into the repository.

Viewport: source and implementation full views used equal `1280 x 720` CSS
viewports. Both browser captures are `1280 x 720` JPEG rasters at the browser's
normalized capture density. The official source asset is `910 x 512` WebP and
is letterboxed at native size inside its full-view capture.

State: authenticated light-theme product detail with an assigned Fragile Goods
profile. The source raster uses the Default profile and a one-channel catalogue;
those are merchant-data differences. The Morrow drawer additionally exercised
open, server-backed search for `def`, selection, clear, restored selection,
loading and successful Save states.

**Findings**

- Shipping-profile destination is implemented and verified
  Location: Shipping configuration profile row.
  Evidence: after assigning the real `Default Shipping Profile` through the
  drawer, the product row rendered the source chevron and opened the live
  `Shipping Profiles › Default Shipping Profile` detail route. The destination
  rendered the profile name, type, back link and actions without browser
  warnings or errors.
  Result: the row reaches the existing server-backed Shipping Profiles
  settings list/detail slice; no new route work is required for this finding.

- [P2] Drawer pixel comparison has no source visual
  Location: Shipping Configuration drawer.
  Evidence: Medusa publishes the detail-card raster but no same-state drawer
  raster was found. The pinned code establishes the title, field, clearable
  combobox and footer structure, but not rendered pixels.
  Impact: drawer typography, overlay geometry and token fidelity cannot receive
  a visual pass.
  Fix: capture a live Medusa drawer at the same viewport and state, combine it
  with Morrow, and repeat the comparison loop.

**Required fidelity surfaces**

- Fonts and typography: card heading, profile label/type hierarchy and drawer
  label match the pinned source structure; drawer pixel fidelity remains open.
- Spacing and layout rhythm: the card now uses the source's 8px outer inset,
  raised component surface, 16px row inset, compact avatar and rounded corners.
  The drawer retains the 560px right-side surface and sticky header/footer.
- Colors and visual tokens: neutral component fill, subtle border/shadow,
  muted profile type and black Save action follow the existing Medusa-mapped
  Admin theme.
- Image quality and asset fidelity: this component has no product imagery. Its
  shopping-bag and chevron use the existing Material icon family; a drawer
  source raster is still required before icon pixel fidelity can pass.
- Copy and content: `Shipping configuration`, `Shipping Configuration`,
  `Shipping Profile`, `Cancel`, and `Save` now match the pinned English source.

**Full-view comparison evidence**

The official raster and revised Morrow detail were emitted together at equal
`1280 x 720` viewports. The source raster is intrinsically letterboxed, so the
pair establishes hierarchy and component composition rather than pixel identity.

**Focused region comparison evidence**

The source card (`910 x 253` crop) and implementation card (`305 x 125` crop)
were emitted together. Their different rendered widths were treated as a scale
difference; heading order, inset surface, icon, label/type stack, chevron,
radii and adjacent Organize card were compared without filing pixel-distance
findings.

**Comparison history**

- The first pair found P2 copy and surface drift: Morrow said `Shipping Profile`
  and rendered a flat divided row. The revised card uses the exact source
  heading and inset elevated link surface; the second pair found no remaining
  P0-P2 card-style mismatch.
- The first revised-route browser pass exposed a zero-width web image that
  produced NaN constraints and flex overflows in the adjacent Media section.
  Explicit image dimensions fixed the layout, and the command bar became a
  dedicated widget class. A fresh browser rendered selection actions with zero
  warnings or errors.
- Pinned source review then found the drawer title and always-open choice list
  diverged from Medusa. Morrow now uses `Shipping Configuration` and a clearable
  searchable combobox. Live search, select, clear and Save passed; the missing
  Medusa drawer raster keeps the visual comparison blocked.

**Implementation checklist**

- Shipping Profile settings list/detail navigation is implemented and browser
  verified. PostgreSQL retained `prod_shirt -> sp_default` after Save.
- Capture the same drawer state from a runnable Medusa Admin.
- Repeat the equal-viewport full and focused comparison before marking this
  slice passed.

**Authenticated browser route evidence**

- Local Admin `13002` authenticated with a QA merchant against API `3878`.
- `T-Shirt` opened its Shipping Configuration drawer, selected
  `Default Shipping Profile`, saved successfully, and exposed the persisted
  profile row.
- Selecting that row opened the profile detail route. The settled Admin browser
  pass reported no warning or error logs.

Admin product shipping-profile slice result: functional route passed; drawer
visual comparison remains open

## Admin Shipping Profiles settings list and detail

Source visual truth paths:

- Pinned source: `/private/tmp/dust-commerce-medusa-reference-20260913/packages/admin/dashboard/src/routes/shipping-profiles/`
- Official list raster: `https://res.cloudinary.com/dza7lstvk/image/upload/fl_lossy/f_auto/r_16/ar_16:9,c_pad/v1/User%20Guide/Screenshot_2025-02-19_at_7.09.44_PM_cq0cwe.png?_a=DATAalkSZAA0`
- Official create raster: `https://res.cloudinary.com/dza7lstvk/image/upload/fl_lossy/f_auto/r_16/ar_16:9,c_pad/v1/User%20Guide/Screenshot_2025-02-19_at_7.13.21_PM_wjp2tm.png?_a=DATAalkSZAA0`
- Official detail raster: `https://res.cloudinary.com/dza7lstvk/image/upload/fl_lossy/f_auto/r_16/ar_16:9,c_pad/v1/User%20Guide/Screenshot_2025-02-19_at_7.14.33_PM_g7egem.png?_a=DATAalkSZAA0`

Implementation screenshot path: in-app browser capture retained in task evidence
for `http://127.0.0.1:13002/` with Shipping Profiles selected.

Viewport: source and implementation were displayed in the same `1280 x 720`
in-app browser surface. The official source file is `2870 x 1614`; the Morrow
capture is `1280 x 720`, both at browser density 1 for the visible comparison.

State: light theme, active list, two Morrow profiles versus four Medusa example
profiles. Merchant data differs; heading, controls, columns, row density and
paging are comparable.

**Findings**

- Query controls are implemented and server-backed
  Location: Shipping Profiles table toolbar.
  Evidence: Morrow renders Add filter on the left and an allowlisted sort menu
  beside Search. Name, Type, Created at and Updated at filters normalize through
  the Admin contract, persist as active chips, clear independently or together,
  and reset paging. The API validates date bounds and order values before the
  SQLx query executes.
  Result: the Medusa query-control workflow is functionally covered; only the
  combined visual-export limitation below remains.

- [P2] Combined comparison export was blocked
  Location: in-app browser evidence board.
  Evidence: both equal-viewport captures opened successfully, but the browser
  security policy rejected the data URL used to place them in one comparison
  board and prohibited an indirect workaround.
  Impact: separate captures support the concrete toolbar finding but do not
  satisfy the blocking combined-image gate.
  Fix: use an allowed native comparison surface in the next QA pass.

**Required fidelity surfaces**

- Fonts and typography: title, subtitle, table labels, row copy and paging use
  the established Medusa-mapped Admin type scale; a combined crop remains due.
- Spacing and layout rhythm: 24px horizontal card inset, 16px header padding,
  compact rows, divider rhythm, radius and full-width single column follow the
  official raster.
- Colors and visual tokens: neutral surfaces, borders, muted copy and destructive
  red action use the existing Admin semantic theme.
- Image quality and asset fidelity: the list/detail/create surfaces contain no
  raster product assets; Material icons remain an intentional library mapping.
- Copy and content: list heading/subtitle, create heading/hint, Type label and
  typed delete copy match the pinned English source.

**Full-view comparison evidence**

The official list and live Morrow list were captured separately at equal
`1280 x 720` viewports. The attempted side-by-side board was blocked by browser
URL policy, so no pass is claimed from separate views.

**Focused region comparison evidence**

No valid combined focused crop exists because the browser policy rejected the
comparison data URL. This is an evidence-export limitation, not a missing
toolbar implementation.

**Comparison history**

- Source-code review established the exact list, create, detail and typed-delete
  responsibilities before implementation.
- Live browser QA passed list, create, detail, typed delete, refresh and product
  link navigation. A hot-reload-only scope error was resolved by the required
  hot restart; no browser errors occurred afterward.
- Official raster review originally exposed the missing Add filter and sort
  controls. The current implementation now exposes both controls and the
  focused ViewModel/API tests pass.

**Validation**

- `flutter test apps/admin_app/test/shipping_profile/admin_shipping_profile_view_model_test.dart apps/admin_app/test/shipping_profile/admin_shipping_profile_detail_view_model_test.dart` passed: 6 tests.
- The authenticated browser list rendered Add filter, Search and sort controls;
  the same session reached the server-backed profile detail route.
- No widget test was added.

Admin Shipping Profiles settings result: functional list/query/detail passed;
combined visual-export evidence remains open

## Store home responsive layout and typography

Source visual truth paths:

- Pinned source at commit `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/home/components/hero/index.tsx`
  and
  `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/home/components/featured-products/product-rail/index.tsx`.
- Live rendered source: `https://next.medusajs.com/dk`.

Implementation screenshot path: in-app browser captures retained in the task
evidence for `http://127.0.0.1:13001/` after the responsive-layout, hero,
product-rail, subtitle-color, and header-typography commits.

Viewport: the desktop pair used equal `1280 x 720` CSS viewports at device-pixel
ratio 2. The browser returned a `1265 x 712` source raster because of the visible
source scrollbar and a `1280 x 720` implementation raster; comparison normalized
the implementation by `1265 / 1280`. The compact pair used equal `390 x 844` CSS
viewports at device-pixel ratio 1. The source capture cropped to `375 x 812`
while the implementation remained `390 x 844`; the implementation was compared
at the same `375 / 390` scale and no finding was filed from browser chrome or
scrollbar crop.

State: public English light-theme home at scroll position zero, followed by one
compact page scroll through the product rail. Medusa renders its own brand,
starter copy, GitHub action, and Clothing products. Morrow intentionally renders
the approved brand, `Powered by dust`, Store action, Featured collection, and
its real dust-commerce demo products.

**Findings**

- No actionable P0, P1, or P2 difference remains in the header, hero, collection
  heading, responsive grid geometry, or compact product rail for this slice.
- Brand, hero copy, action copy, collection names, prices, and product images are
  intentional product and merchant-data differences rather than design drift.

**Required fidelity surfaces**

- Fonts and typography: the live Medusa header computes the brand at `18px/20px`
  weight 500 and actions at `12px/20px` weight 400. Its hero headings compute at
  `32px/40px` weight 600 despite conflicting authored utility classes. Morrow now
  matches those rendered values. The rail heading and View all link use the
  pinned `Text`/`text-base` contract at `16px/24px` weight 400.
- Spacing and layout rhythm: both storefronts use a 64px header, a `75vh` hero,
  a 24px hero action gap, 24px horizontal rail inset, 32px rail-header gap,
  two compact columns, 24px column spacing, and 96px compact row spacing. The
  measured compact hero boundary is 697px in both implementations.
- Colors and visual tokens: the title uses `#18181b`, the subtitle and header use
  `#52525b`, the interaction link uses `#3b82f6`, and the subtle background and
  border remain mapped to the existing Store tokens.
- Image quality and asset fidelity: each backend uses real merchant product
  imagery. The compact Morrow rail rendered sharp source-hosted product images
  with the established source card treatment; no placeholder or code-drawn
  asset was introduced.
- Copy and content: Morrow retains the user-approved `MORROW`, `Everyday
  essentials, considered.`, `Powered by dust`, and `Shop products` copy. The
  source-specific Medusa/GitHub wording is intentionally not copied as product
  identity.

**Full-view comparison evidence**

The live Medusa and Morrow desktop captures were emitted together at equal
`1280 x 720` CSS viewports. A second combined input compared both at equal
`390 x 844` CSS viewports. Header geometry, hero centering, `75vh` boundary,
button placement, rail header alignment, and above-the-fold density align after
normalizing the source scrollbar crop.

**Focused region comparison evidence**

The compact full-view pair keeps the complete header, hero type, button, border,
rail heading, View all link, and first product row legible in one frame, so a
separate crop was not needed. A one-page compact scroll additionally exposed the
two-column product cards, wrapped titles, prices, images, and row rhythm.

**Comparison history**

- The first full-page stress capture produced a negative product-card width and
  cascading Flutter layout assertions. Commit `f13269f` sizes grids from their
  real constraints, falls back to one column before spacing can become negative,
  and guards transient zero-width AppBar and hero frames.
- Fresh full-page and normal captures after `f13269f` completed without a red
  assertion band or browser warning. The `390 x 844` product rail also rendered
  two working columns without overflow.
- The first equal compact pair found 30px normal-weight hero copy, a muted-value
  error, a 24px collection heading, and a 12px centered brand. Commits `d1407cf`,
  `e7138ae`, `61adc95`, and `581f40e` match the live computed hero, subtitle,
  rail, brand, and action tokens as separate stacked responsibilities.
- The final equal compact and desktop pairs produced no browser warning or error.
  Store analysis, all 136 Store tests, Dust generation checks, formatting, and
  the file-size budget passed. No widget test was added.

**Implementation checklist**

- No remaining fix is required for this home slice.
- Continue the same source-code-first, matched-viewport loop for the next
  unresolved customer route already listed above.

Store home responsive layout and typography result: passed

## Store compact product layout and related cards

Source visual truth paths:

- Pinned source at commit `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/products/templates/index.tsx`,
  `templates/product-info/index.tsx`, `components/image-gallery/index.tsx`,
  `components/product-actions/{index.tsx,mobile-actions.tsx,option-select.tsx}`,
  `components/product-tabs/index.tsx`, and
  `components/related-products/index.tsx`.
- Live rendered sources:
  `https://next.medusajs.com/dk/products/espresso-cup` and
  `https://next.medusajs.com/dk/products/hoodie`.

Implementation URL:
`http://127.0.0.1:13001/products/t-shirt?v_id=var_tshirt_m_black`.
The implementation and source captures were emitted together by the in-app
browser and retained in the task evidence.

Viewport: every final comparison used equal `390 x 844` CSS viewports and
`390 x 844` output rasters at device-pixel ratio 1.

State: public English light theme with a selected, in-stock variant. The source
used Hoodie with its only live Default option value; Morrow used Essential
T-Shirt with Size M and Color Black. A second pair opened each compact option
surface. The live Medusa fixture rendered an empty option body because its
products expose only one variant, while Morrow correctly rendered its richer
Size and Color controls. Related-product headings and two-column cards were
compared below the fold.

**Findings**

- No actionable P0, P1, or P2 difference remains in the matched compact page
  rhythm, gallery, sticky purchase chrome, related heading, or related-card
  layout.
- The live source cannot provide a populated multi-option or unavailable
  combination state. Morrow's additional controls are real merchant-data
  behavior, so their contents are not claimed as a pixel-matched source pair.

**Required fidelity surfaces**

- Fonts and typography: title, description, accordion labels, sticky product
  summary, price, option labels, and related heading use the established Store
  scale. Merchant title and description length are intentionally different.
- Spacing and layout rhythm: both use a 64px header, 24px page inset, 32px
  compact product-column inset, 32px transition into the gallery, `29 / 34`
  gallery ratio, 16px sticky action padding, and a two-column related grid with
  24px column and 32px row gaps.
- Colors and visual tokens: base, subtle, muted, border, selected interactive,
  disabled, overlay, and primary-action colors remain mapped through Store
  semantic tokens.
- Image quality and asset fidelity: both render real merchant images in the
  source-authored aspect ratios. No placeholder or synthetic product asset was
  introduced.
- Copy and content: Morrow retains its approved brand, product data, USD price,
  and `Powered by dust` identity. Source-specific Medusa product copy is not
  copied as merchant data.

**Full-view comparison evidence**

The initial matched pair exposed Morrow's product information 32px too high.
Commit `9a87e9d` adds the missing source `py-8` compact inset. The final pair
aligns the collection baseline and product column; subsequent vertical
difference is exactly explained by Medusa's five-line description versus
Morrow's two-line description. Fresh local captures had no browser warnings or
errors.

**Focused region comparison evidence**

The option-sheet pair confirms the same bottom-aligned overlay, 48px circular
close control, border rhythm, and compact action entry. It does not claim equal
option-body density because the live source has no multi-variant fixture. The
first focused related-grid capture exposed Flutter overflow stripes on every
card. Commit `23f4aec` replaces the fixed-height grid with content-sized card
columns; the final focused capture shows two clean rows with no overflow or
browser warning.

**Comparison history**

- Source code was inspected before the first capture and established the
  compact template, option, mobile-action, gallery, tab, and related-product
  contracts.
- Equal-viewport Espresso Cup and Hoodie comparisons isolated the missing
  compact top inset from ordinary merchant-copy and image differences.
- Commit `57c07cd` replaces the forbidden private `Widget`-returning helper
  with a private widget class without changing behavior.
- Dust reports all 54 Store sources clean, Flutter analysis passes, all 136
  Store tests pass, handwritten formatting and the file-size gate pass, and no
  widget test was added.

**Implementation checklist**

- No remaining fix is required for the compact product-layout and related-card
  surfaces covered by this slice.
- Retain the wider option functionality and capture a truly matched populated
  or unavailable-combination pair when the live source exposes that state.

Store compact product layout and related cards result: passed

## Store checkout composition and customer journey

Source visual truth paths:

- Pinned source at commit `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/tmp/medusa-dtc-19e8a6f/apps/storefront/src/modules/checkout/components/shipping-address/index.tsx`,
  `addresses/index.tsx`, `country-select/index.tsx`, `shipping/index.tsx`,
  `payment/index.tsx`, `address-select/index.tsx`,
  `templates/checkout-form/index.tsx`, and
  `templates/checkout-summary/index.tsx`.
- Pinned route and layout sources:
  `/tmp/medusa-dtc-19e8a6f/apps/storefront/src/app/[countryCode]/(checkout)/checkout/page.tsx`
  and `layout.tsx`.
- Live rendered source:
  `https://next.medusajs.com/dk/checkout?step=address`.

Implementation URL:
`http://127.0.0.1:13001/checkout?step=address`.

Viewport: the compact source and implementation comparison used equal
`390 x 844` CSS viewports at device-pixel ratio 1. The source capture was
cropped by its browser surface to a `375 x 812` raster while the implementation
capture retained `390 x 844`; findings were made from the shared CSS viewport
and normalized content region, not the crop.

State: public English light theme with populated anonymous carts. The live
source rendered two iPhone units in EUR and Morrow rendered two T-shirt units
in USD; both summaries used real server-owned products, quantities, prices and
totals. Merchant content and currency differ, while checkout state and
composition are directly comparable.

**Findings**

- No actionable P0, P1, or P2 difference remains in the compact checkout
  header, address title, two-column field grid, country control, billing toggle,
  contact row, primary action, or collapsed Delivery and Payment sections.
- The first populated pair exposed Morrow's fixed 240px AppBar leading slot:
  compact Back and brand controls were both shifted right. Commit `a368ee2`
  uses a 96px compact slot while retaining 240px for the desktop label, and
  gives the brand the source's 18px/20px medium treatment. The final pair puts
  Back at the 24px gutter and centers the brand.
- Blank submission uses native browser validation in the React source and
  readable inline Flutter validation in Morrow. Both block invalid progress;
  exact validation-popover raster parity is not claimed.

**Required fidelity surfaces**

- Fonts and typography: checkout headings, labels, summaries, totals, product
  lines, and primary actions retain the established Store scale and hierarchy.
- Spacing and layout rhythm: the compact form uses the pinned two-column address
  grid, 16px inter-field gap, section dividers, and vertically ordered address,
  delivery, payment, review, and cart-summary content.
- Colors and visual tokens: inputs, borders, muted summaries, selected radio
  controls, interaction links, and primary buttons remain mapped to Store
  semantic colors.
- Copy and content: Morrow keeps its real customer, cart, product, price,
  delivery, and payment data plus the approved `Powered by dust` footer.

**Full-view comparison evidence**

The populated source and Morrow address pages were emitted together from equal
compact CSS viewports. Their checkout shell, 64px header, left Back control,
centered brand, address hierarchy, field matrix, billing row, contact row,
Continue action, collapsed next-step sections and real cart-summary structure
align. The screenshot captures remain current-run session evidence rather than
a persisted filesystem artifact.

**Focused region comparison evidence**

After the refactor, a fresh local compact journey submitted a fake QA address,
selected United States, chose Standard shipping and Manual Payment, and reached
the Review step. The review showed the server-owned USD 15.00 subtotal, USD
5.00 shipping, USD 2.00 taxes, and USD 22.00 total. Testing stopped before
`Place order`, and the browser reported no warning or error.

**Comparison history**

- Source inspection established the compact one-column checkout and desktop
  form-plus-summary contracts before implementation review.
- Commits `d009a82`, `4466f52`, `71b82bf`, `0584fe8`, `f9b40f8`, and `8bfd6a6`
  replace all 14 checkout private methods returning `Widget` with focused widget
  classes while preserving state and async mutation ownership.
- Checkout files remain within the 180-line handwritten limit. Dust reports all
  54 Store sources clean, Flutter analysis passes, all 139 Store tests pass,
  formatting, file-size and structure gates pass, and no widget test was added.
- The settled source and rebuilt release Store tabs reported no browser warning
  or error.

**Implementation checklist**

- The address-through-review customer flow is working against the local backend
  and needs no further composition refactor in this slice.
- Same-state source comparison of delivery, payment, review and confirmation
  remains separate work; no source address was submitted in this pass.

Store checkout composition and customer journey result: passed

## Store authenticated account composition

Source visual truth paths:

- Pinned Medusa DTC source at commit
  `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/account/templates/account-layout.tsx`,
  `components/account-nav/index.tsx`, `components/overview/index.tsx`,
  `components/account-info/index.tsx`, `components/profile-name/index.tsx`,
  `components/profile-password/index.tsx`,
  `components/profile-billing-address/index.tsx`,
  `components/address-book/index.tsx`,
  `components/address-card/add-address.tsx`, and
  `components/address-card/edit-address-modal.tsx`.
- Saved-address checkout behavior was also checked against
  `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/checkout/components/addresses/index.tsx`,
  `address-select/index.tsx`, and `country-select/index.tsx`.

Implementation URLs:
`http://127.0.0.1:13001/account`, `/account/profile`,
`/account/addresses`, and `/checkout?step=address`.

Viewport: the authenticated account overview was verified at the default
`1280 x 720` browser viewport at device-pixel ratio 1. The complete
product-to-checkout saved-address journey was also verified at an isolated
`390 x 844` CSS viewport at device-pixel ratio 1. The temporary compact
viewport override was reset after QA.

State: English light theme, signed in with a fake local QA customer. The local
account has one persisted address and no recent orders. No customer secret is
recorded here. The live Medusa deployment did not provide an equivalent
authenticated customer session, so the source-code contract and local rendered
state were reviewed, but authenticated pixel parity is not claimed.

**Findings**

- The local overview follows the source hierarchy: account navigation, customer
  greeting, signed-in identity, profile completion, saved-address count, recent
  orders, help callout, and Store footer.
- Profile name and password editors retain the source two-column desktop grid.
  New addresses start blank, while edit forms load only the selected persisted
  address.
- Route guarding now reuses a server-proven authenticated customer instead of
  forcing identity restoration on every private route. Address loading retries
  after identity restoration, preventing a valid saved address from appearing
  empty during a route transition.
- Private API responses default to `Cache-Control: no-store`; immutable public
  media keeps its explicit cache policy.
- No actionable browser warning or error was reported during the isolated
  product, cart, checkout, and saved-address selection journey.

**Required fidelity surfaces**

- Fonts and typography: account headings, completion values, navigation,
  address cards, editor labels, and supporting copy use the established Store
  scale.
- Spacing and layout rhythm: desktop account navigation and content columns,
  two-column editor fields, overview metrics, section dividers, and compact
  checkout fields follow the pinned source composition.
- Colors and visual tokens: neutral borders, muted metadata, blue interaction
  links, selected controls, and primary actions use Store semantic tokens.
- Copy and content: the UI renders real server-owned customer and address data
  and retains the approved `Powered by dust` footer.

**Full-view comparison evidence**

The settled local account overview visibly rendered `Hello Ada`, the QA email,
`50% COMPLETED`, `1 SAVED`, `No recent orders`, the customer-service callout,
and the complete footer. The source implementation files establish the same
information architecture. A matched authenticated Medusa raster was unavailable,
so this evidence supports composition and behavior, not pixel parity.

**Focused region comparison evidence**

An isolated local journey opened the T-shirt product, added its selected variant
to a real cart, entered checkout, opened the saved-address selector, selected
`Ada Morrow / 1 Test Street / SW1A 1AA, London / GB`, and observed the first
name, last name, street, postal code, city, country, and email fields populate.
Testing stopped before order placement.

**Comparison history**

- Source inspection established the account navigation, overview, editor, and
  address-book contracts before the final browser pass.
- Commits `fca7b5b`, `ed962d7`, `9d8f962`, `2a8fc43`, `d773b96`, and `7ed59ce`
  split navigation and editor widgets while preserving page-owned state.
- Commits `22b85b6`, `38391ed`, and `aabdbe0` close address restoration, private
  caching, and route-guard races. Commit `967387d` updates the enforced widget
  debt baseline after those extractions.
- Dust checks are clean for 63 Admin-contract, 39 Store-contract, 152 server,
  54 Store, 71 Admin, and 137 database sources. Analysis passes for all five
  Dart/Flutter packages. Tests pass: 38 Admin-contract, 146 Store-contract,
  553 server, 137 Store, and 162 Admin tests. SQLx applies all 63 one-table
  reversible migrations and reverts them to zero application tables. Formatting,
  file-size, structure, and diff checks pass. No widget test was added.

**Implementation checklist**

- Authenticated profile and address management are working against the local
  backend, and a saved address can drive the real checkout form.
- Capture a matched authenticated Medusa account raster if a disposable source
  login becomes available; do not infer that visual state from source code.

Store authenticated account composition result: passed

## Store authenticated order history and detail

Source truth paths:

- Pinned Medusa DTC source at commit
  `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/account/components/order-overview/index.tsx`,
  `components/order-card/index.tsx`, and
  `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/order/templates/order-details-template.tsx`.
- The source uses `Date.toDateString()` for a year-bearing order date and
  selects singular `item` only when the total quantity is one.

Implementation URLs: the official Store remains
`http://127.0.0.1:13001/account/orders`. A temporary release Store on
`http://127.0.0.1:13004/account/orders` isolated the populated QA identity
from the existing `13001` account session.

Viewport: the order list was verified at the default `1280 x 720` browser
viewport and at `390 x 844`, both at device-pixel ratio 1. The detail route
was also verified at `390 x 844`. The temporary viewport override was reset
after QA.

State: English light theme, signed in with a fake local QA customer. Three
server-created orders exercised quantities one, two, and three, distinct
products, EUR totals, and captured versus awaiting payment states. No customer
secret is recorded here.

**Findings and correction**

- Populated browser evidence exposed `1 items` in the local card while the
  source renders `1 item`.
- Local account, confirmation, payment, and return dates used a medium date
  without the calendar year; the source order views include the year.
- Commit `6c9e1cd` centralizes customer-facing date and date-time formatting,
  retains the year, and supplies explicit singular and plural order/return
  translations without changing server-owned timestamps.
- The settled desktop and compact order list renders `1 item`, `2 items`,
  `3 items`, and `Tue, Sep 15, 2026`. The compact detail renders the same full
  date, order/payment status, line item, delivery, address, contact, method,
  and totals without overflow.
- The final browser pass reported no warning or error logs.

**Comparison boundary**

The pinned source implementation establishes the hierarchy, copy, plural
rule, date semantics, card media, and detail-section order. No disposable
authenticated Medusa session or matched raster was available, so this pass
proves source-structure and local behavior parity, not pixel parity.

**Validation**

- Store release Web build succeeded for the populated QA pass.
- All 139 Store tests pass, including two focused date-format tests; no widget
  test was added.
- Flutter analysis reports no issue; Dust reports all 54 Store outputs clean.
- Dust i18n checks 684 translations with zero errors; its 15 warnings are the
  existing stale/equal-fallback inventory outside this slice.
- Handwritten formatting, the frozen 180-line baseline, widget composition,
  backend response boundaries, and diff whitespace checks pass.

Store authenticated order history and detail result: passed

## Store language selector

Source truth paths:

- Pinned Medusa DTC source at commit
  `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/modules/layout/components/language-select/index.tsx`,
  `components/side-menu/index.tsx`,
  `/private/tmp/dtc-starter-reference-20260913/apps/storefront/src/lib/data/locales.ts`,
  and `lib/data/locale-actions.ts`.
- Live source:
  `https://next.medusajs.com/dk/products/espresso-cup?v_id=variant_01KA906CNZ2951NNN2GDFV1QF8`,
  `/products/electric-bike?v_id=variant_01KA90S8C45YNQCAX3NJ2W9MV1`, and
  `/products/hoodie?v_id=variant_01KBNDBWA7DXVAZXSW9382X261`.

Implementation URL: a temporary release Store at
`http://127.0.0.1:13004/products/t-shirt?v_id=var_tshirt_m_black` isolated
language preference QA from the official Store session. The final build remains
available at `http://127.0.0.1:13001`.

Viewport and state: English light theme at the default `1280 x 720` viewport,
plus Morrow compact QA at `390 x 844`, device-pixel ratio 1. Morrow had the
Dust-compiled `en` and `my` locales; the live Medusa deployment returned no
configured locales and therefore correctly hid its conditional Language row.
The temporary viewport override was reset after QA.

**Source and behavior findings**

- Both menus use the same inset translucent panel, four primary destinations,
  bottom preference rows, 16px flags, a trailing directional arrow, and a
  rights line. Morrow adds only its approved branding and `Powered by dust`
  treatment elsewhere in the Store shell.
- The pinned selector includes Default plus configured locales, localizes each
  language name, persists the choice, refreshes the current route, and closes
  the side menu after selection.
- Morrow already persisted only supported Dust locale codes and restored them
  before routing, but its drawer remained open after selection.
- Commit `5f5a766` closes the drawer after a successful language change and
  replaces the selector's private `Widget` helper with a real widget class.
  Commit `073f431` removes that resolved debt from the frozen structure
  baseline.
- Release-browser QA selected Burmese from a T-shirt detail page, observed the
  drawer close, retained `/products/t-shirt?v_id=var_tshirt_m_black`, rendered
  the translated Flutter chrome, survived a hard reload, and cleared back to
  Default. The final browser pass reported no warning or error logs.

**Comparison boundary**

The live source has no configured locales, so it supplies authoritative
unconfigured-menu geometry but no selector popup raster. Morrow's `en` and
`my` bundles are explicit application configuration and permit the source
interaction to be exercised locally. Product titles and descriptions remain
server-owned English because dust-commerce has no localized-content module;
this pass does not claim translated commerce data or Medusa cart-locale
semantics.

**Validation**

- The Store release Web build succeeded.
- All 139 Store tests pass; the five focused shell tests cover supported,
  unsupported, persisted and cleared locale state. No widget test was added.
- Flutter analysis reports no issue; Dust reports all 54 Store outputs clean.
- Dust i18n checks 684 translations with zero errors; its 15 warnings remain
  the existing stale/equal-fallback inventory outside this slice.
- Handwritten formatting, file-size, widget composition, response boundaries,
  and diff whitespace checks pass.

Store language selector result: passed for configured local behavior; matched
configured-source raster unavailable

## Store country selector behavior

Source truth paths:

- Pinned Medusa DTC source at commit
  `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/tmp/medusa-dtc-19e8a6f/apps/storefront/src/modules/layout/components/country-select/index.tsx`,
  `components/side-menu/index.tsx`, `lib/data/cart.ts`, and
  `lib/data/regions.ts`.
- Live source:
  `https://next.medusajs.com/dk/products/espresso-cup?v_id=variant_01KA906CNZ2951NNN2GDFV1QF8`.

Implementation URL: a temporary release Store at
`http://127.0.0.1:13004/products/t-shirt?v_id=var_tshirt_m_black` isolated
country and cart persistence from the official Store session. The final build
remains available at `http://127.0.0.1:13001`.

Viewport and state: English light theme with a one-item T-shirt cart at the
default `1280 x 720` viewport, plus local compact QA at `390 x 844` and
device-pixel ratio 1. The live source country list was captured in its Denmark
product state before implementation. The temporary viewport override was
reset after QA.

**Source and behavior findings**

- The pinned selector derives alphabetized choices from active regions, uses
  16px SVG flags, updates any existing cart, preserves the current path and
  closes the side menu immediately after selection.
- Morrow already derived countries from its active region response, persisted
  a supported country, restored it before routing, and accepted only the
  server's atomic cart repricing and regional shipping reset. Its drawer stayed
  open after a successful selection.
- Commit `6a1de88` closes the drawer only after both cart and shell selection
  succeed and replaces the private `Widget` flag helper with a focused widget
  class. Commit `db50d7e` removes that resolved debt from the frozen structure
  baseline.
- Release-browser QA changed a one-item cart from Denmark/EUR to United
  States/USD on `/products/t-shirt?v_id=var_tshirt_m_black`. The drawer closed,
  the exact product URL and variant remained, the price changed from EUR 10.00
  to USD 15.00, the cart retained one item with a USD 16.50 total, and country,
  currency and cart survived a hard reload. Resetting to Denmark restored the
  EUR 10.00 cart and closed the compact drawer. Browser logs contained no
  warnings or errors.

**Comparison boundary**

The local backend exposes eight configured countries while the live Medusa
deployment exposes fourteen; both selectors correctly render their active
region inventory. The behavior pass originally found a P2 visual mismatch:
Morrow's list was content-width, title case, 48px per row and viewport-clamped
below its trigger, while the source uses a 320px uppercase panel above it.
Commit `467b8cd` corrects that mismatch without changing region behavior.

**Popup comparison evidence**

- Source visual truth: the live URL above, captured open in the in-app Browser
  at `1280 x 720` CSS pixels and `1280 x 720` image pixels, device-pixel ratio
  1. The pinned source file above supplies the corresponding classes.
- Rendered implementation: the temporary release URL above, captured open at
  `1280 x 720` CSS/image pixels and at `390 x 844` CSS/image pixels, both at
  device-pixel ratio 1. The safe browser capture is session evidence and was
  not exported to a filesystem screenshot path.
- Source DOM measurement: the panel is `320 x 442`, ends at y=604, and sits
  8px above a 28px trigger at y=612. Its first row is 36px high with 12px type,
  20px line height, 12px horizontal padding, an 8px flag gap, uppercase text,
  an 8px radius and the source drop shadow.
- Implementation measurement: the eight-country panel is `320 x 288`, uses
  the same 36px rows, typography, padding, gap, uppercase treatment and radius,
  and ends at y=595 exactly 8px above its 40px Flutter trigger at y=603. The
  different panel height is expected configured data, not layout drift.
- Full-view and focused drawer captures show the panel aligned at x=32 on both
  desktop implementations. The compact capture keeps the complete 320px panel
  inside a 390px viewport with the trigger and footer reachable.
- The browser refused the generated data-URL comparison board under its URL
  safety policy. Because the two captures could not be placed into one combined
  comparison artifact, this formal visual pass remains blocked rather than
  claiming pixel parity from separate images.

**Required fidelity surfaces**

- Fonts and typography: Inter, 12px regular, 20px line height and uppercase
  option labels match the measured source values.
- Spacing and layout rhythm: width, row height, inset, padding, gap, radius and
  8px anchor separation match; total height differs only with active countries.
- Colors and visual tokens: both use a white panel, black option copy, real
  country colors and a neutral drop shadow.
- Image quality and asset fidelity: both render real 16px SVG country flags;
  no emoji, text glyph or drawn substitute is used.
- Copy and content: country names come from each backend's active-region data.
  Morrow's eight-country inventory intentionally differs from Medusa's current
  fourteen-country deployment.

**Interaction evidence**

At `390 x 844`, selecting United States closed the drawer, retained
`/products/t-shirt?v_id=var_tshirt_m_black`, repriced the selected T-shirt from
EUR 10.00 to USD 15.00, retained the one-item cart, and survived a hard reload.
The final compact browser pass reported no warning or error logs. The temporary
viewport override was reset.

**Validation**

- The Store release Web build succeeded.
- All 139 Store tests pass; the seven focused cart-region and shell tests pass.
  No widget test was added.
- Flutter analysis reports no issue; Dust reports all 54 Store outputs clean.
- Dust i18n checks 684 translations with zero errors; its 15 warnings remain
  the existing stale/equal-fallback inventory outside this slice.
- Handwritten formatting, file-size, widget composition, response boundaries,
  and diff whitespace checks pass.

Store country selector behavior result: passed; formal combined popup visual
comparison remains blocked by the unavailable comparison artifact

## Store compact populated cart

Source truth paths:

- Pinned Medusa DTC source at commit
  `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/tmp/medusa-dtc-19e8a6f/apps/storefront/src/modules/cart/templates/index.tsx`,
  `templates/items.tsx`, `templates/summary.tsx`, and
  `components/item/index.tsx`.
- Live source: `https://next.medusajs.com/dk/cart`.

Implementation URL: `http://127.0.0.1:13001/cart`.

Viewport and state: English light theme and an anonymous populated cart at a
nominal `390 x 844` CSS viewport. The live source capture was cropped to a
`375 x 812` raster by its visible horizontal scrollbar; the Flutter capture
retained the complete `390 x 844` viewport. Source and implementation captures
were emitted together in the same comparison input. They remain current-run
session evidence rather than a persisted filesystem screenshot artifact.

**Source and behavior findings**

- The pinned source renders the anonymous sign-in prompt, 32px Cart heading,
  Item/Quantity/Total compact header, 48px thumbnail, delete action, 40px
  quantity control, Summary, promotion entry, server totals, and checkout link.
- Morrow renders the same hierarchy and control order from its Dust cart
  response. Its real T-shirt data and USD prices intentionally differ from the
  live source's iPhone fixture and EUR prices.
- At this compact width the live source table exceeds the viewport: the Total
  header and value are clipped and the page exposes a horizontal scrollbar.
  Morrow keeps Item, Quantity, and Total inside the viewport. This is an
  intentional native-mobile correction, not a source defect copied forward.
- The matched captures show the same 24px page inset, prompt divider, heading
  scale, table-divider rhythm, neutral quantity pill, promotion link, and
  one-column Summary placement. Differences in row height follow the source's
  longer product title and variant copy.

**Interaction evidence**

- Local keyboard selection changed quantity from 1 to 2. The header count and
  line total changed atomically from 1 to 2 and USD 15.00 to USD 30.00; subtotal,
  tax, and grand total changed from USD 15.00, USD 1.50, and USD 16.50 to
  USD 30.00, USD 3.00, and USD 33.00.
- The settled source and implementation tabs reported no browser warning or
  error. Removal was not repeated through the browser because automated tests
  already cover it and this pass did not need to destroy the captured cart.

**Evidence limits**

- The nominal viewport is shared, but the source's own scrollbar changes its
  output raster by 15px. The comparison therefore establishes responsive
  structure and behavior, not pixel equality.
- Screenshots could be displayed together but not exported to a local file by
  the browser surface. Formal persisted screenshot-audit completion is not
  claimed.

**Validation**

- A clean checkout generated 365 ignored Dust outputs with no tracked
  `.g.dart` or unexpected source changes.
- All 63 SQLx migration pairs ran up and down to an empty application schema.
- All five analyzers, handwritten formatting, 1,038 tests, the file-size gate,
  and the backend structure gate pass. No widget test was added.

Store compact populated cart result: passed for responsive structure and live
quantity behavior; persisted screenshot-artifact evidence remains unavailable

## Store compact signed-out account

Source truth paths:

- Pinned Medusa DTC source at commit
  `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/tmp/medusa-dtc-19e8a6f/apps/storefront/src/modules/account/templates/account-layout.tsx`,
  `login-template.tsx`, and `components/{login,register}/index.tsx`.
- Live source: `https://next.medusajs.com/dk/account`.

Implementation URL: `http://127.0.0.1:13001/account`.

Viewport and state: English light theme and signed-out account state at a
nominal `390 x 844` CSS viewport. The live source capture was cropped to a
`375 x 812` raster by its visible scrollbar; the Flutter capture retained the
complete `390 x 844` viewport. Source and implementation captures were emitted
together in the same comparison input. They remain current-run session evidence
rather than a persisted filesystem screenshot artifact.

**Source and behavior findings**

- The pinned source uses one 384px-max form, 32px inner padding, an in-place
  sign-in/register switch, and a support block below the account content.
- Morrow preserves the form hierarchy, field order, required markers, password
  visibility control, primary action, membership switch, 24px page inset, and
  source spacing. Product-name substitutions are intentional brand adaptation.
- Registration exposes first name, last name, email, optional phone, password,
  terms copy, Join, and the return-to-sign-in action in the same source order.
- The first compact comparison exposed a responsive defect in `AccountSupport`:
  the local desktop row narrowed the support paragraph. The implementation now
  follows the source's compact column, keeping the help copy full-width and the
  Customer Service link on its own right-aligned row with a 32px gap.

**Interaction evidence**

- Both live pages switched from Sign in to Register and back in place without
  navigation or submission.
- No source form was submitted and no account was created.
- The settled source tab reported no browser log entry. The local tab reported
  only Flutter bootstrap debug entries, with no warning or error.

**Evidence limits**

- Browser autofill briefly projected a previously saved value into one local
  registration field; this was browser-owned state and is not application data.
- The nominal viewport is shared, but the source scrollbar changes its output
  raster by 15px. The comparison establishes responsive structure and behavior,
  not pixel equality.
- Screenshots were displayed together but could not be exported to a local file
  by the browser surface. Formal persisted screenshot-audit completion is not
  claimed.

**Validation**

- The Store release Web build succeeded and the updated route was recaptured.
- All 139 Store tests pass; Flutter analysis reports no issue.
- Dust reports all 54 Store outputs clean. Dust i18n checks 684 translations
  with zero errors; its 15 warnings remain the existing stale/equal-fallback
  inventory outside this slice.
- Handwritten formatting, file-size, response-boundary, project-structure, and
  diff whitespace checks pass. No widget test was added.

Store compact signed-out account result: passed for responsive structure and
the sign-in/register interaction; persisted screenshot-artifact evidence remains
unavailable

## Store compact product tabs

Source truth paths:

- Pinned Medusa DTC source at commit
  `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/tmp/medusa-dtc-19e8a6f/apps/storefront/src/modules/products/templates/index.tsx`,
  `components/product-tabs/{index,accordion}.tsx`, and
  `components/product-actions/mobile-actions.tsx`.
- Live source:
  `https://next.medusajs.com/dk/products/espresso-cup?v_id=variant_01KA906CNZ2951NNN2GDFV1QF8`.

Implementation URL:
`http://127.0.0.1:13001/products/heavyweight-black-tee?v_id=var_demo_02`,
`/products/swim-shorts?v_id=var_demo_16`, and
`/products/t-shirt?v_id=var_tshirt_m_black`.

Viewport and state: English light theme, one in-stock simple product, and a
nominal `390 x 844` CSS viewport. The live source capture was cropped to a
`375 x 812` raster by its visible scrollbar; the Flutter capture retained the
complete `390 x 844` viewport. Source and implementation captures were emitted
together in each comparison input. They remain current-run session evidence
rather than a persisted filesystem screenshot artifact.

**Source and behavior findings**

- Both pages preserve the source order: collection, title, description, two
  independent tabs, gallery, inline purchase controls, related products, and a
  bottom mobile purchase surface once the inline action leaves the viewport.
- The first open-tab comparison exposed Material defaults not present in the
  source: a full-row gray interaction wash and a blue chevron. A dedicated
  `ProductTab` now keeps the row white and uses the source's neutral plus/minus
  state with a 300ms transition.
- The Shipping & Returns comparison exposed paraphrased local body copy. All
  three English descriptions now match the pinned source exactly.
- Shipping icons now use the source's 16px scale and 8px content gap.
- Titles, prices, product facts, image counts, and raster assets intentionally
  differ because Medusa serves Espresso Cup while Morrow serves Heavyweight
  Black Tee. Those merchant-data differences were not encoded as UI changes.

**Interaction evidence**

- Product Information opened independently on both pages and exposed the same
  two-column fact hierarchy.
- Shipping & Returns then opened independently on both pages and exposed the
  same three icon, title, and body rows in the same order.
- At `390 x 780`, Medusa Electric Bike and Morrow Swim Shorts both exposed the
  fixed title row and disabled gray `Out of stock` action once their inline
  purchase control was outside the viewport. Morrow's USD price remains a real
  merchant-data difference; the live Electric Bike renders no price.
- Medusa Hoodie and Morrow Essential T-Shirt opened equivalent compact option
  sheets with the same dimmed backdrop, bottom-aligned white panel, 48px close
  control at the 24px gutter, and 12px panel separation. Panel height and body
  content differ because the live Hoodie has one generated default option and
  therefore renders an empty body, while Morrow exposes real Size and Color
  choices.
- The settled source tab reported no browser log entry. The local tab reported
  only Flutter bootstrap debug entries, with no warning or error.

**Evidence limits**

- The nominal viewport is shared, but the source scrollbar changes its output
  raster by 15px. The comparison establishes responsive structure and behavior,
  not pixel equality.
- Equivalent simple and sold-out products are covered. A matched
  unavailable-combination and post-add state still depends on equivalent live
  source data.
- Screenshots were displayed together but could not be exported to a local file
  by the browser surface. Formal persisted screenshot-audit completion is not
  claimed.

**Validation**

- The Store release Web build succeeded and the final route was recaptured.
- All 139 Store tests pass; Flutter analysis reports no issue.
- Dust reports all 54 Store outputs clean. Dust i18n checks 684 translations
  with zero errors; its 15 warnings remain the existing stale/equal-fallback
  inventory outside this slice.
- Handwritten formatting, file-size, response-boundary, project-structure, and
  diff whitespace checks pass. No widget test was added.

Store compact product tabs result: passed for equivalent simple-product layout,
accordion interaction, source copy, sold-out action, and option-sheet chrome;
persisted screenshot-artifact evidence remains unavailable

## Store not-found route

Source truth paths:

- Pinned Medusa DTC source at commit
  `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/tmp/medusa-dtc-19e8a6f/apps/storefront/src/app/not-found.tsx` and
  `/tmp/medusa-dtc-19e8a6f/apps/storefront/src/app/[countryCode]/(main)/not-found.tsx`.
- Live source: `https://next.medusajs.com/dk/does-not-exist`.

Implementation URL: `http://127.0.0.1:13001/does-not-exist`, which resolves to
the local `/404` route.

Viewport and state: English light theme at an exact `390 x 844` CSS viewport.
Source and implementation captures had equal `390 x 844` rasters and were
emitted together in the comparison input. They remain current-run session
evidence rather than persisted filesystem screenshot artifacts.

**Source and behavior findings**

- The original local fallback was one unstyled sentence. It now matches the
  source hierarchy and exact English copy: a 30px semibold heading with 48px
  line height, 16px vertical gaps, 12px explanatory copy with 20px line height,
  and the shared underlined interactive-link treatment.
- The content group preserves the source's 64px bottom offset. The root fallback
  intentionally excludes storefront navigation and footer because the live
  root not-found route does the same.
- English and Burmese strings are compiled through Dust i18n rather than
  embedding one-locale UI state.

**Interaction evidence**

- Activating `Go to frontpage` navigated the local release build from `/404` to
  `/` and loaded the catalogue home successfully.
- The settled source tab reported no browser log entry. The local tab reported
  only Flutter bootstrap debug entries, with no warning or error.

**Evidence limits**

- Screenshots were displayed together but could not be exported to a local file
  by the browser surface. Formal persisted screenshot-audit completion is not
  claimed.

**Validation**

- The Store release Web build succeeded and the final route was recaptured.
- All 139 Store tests pass; Flutter analysis reports no issue.
- Dust reports all 54 Store outputs clean. Dust i18n checks 688 translations
  with zero errors; its 15 warnings remain the existing stale/equal-fallback
  inventory outside this slice.
- Handwritten formatting, file-size, response-boundary, project-structure, and
  diff whitespace checks pass. No widget test was added.

Store not-found result: passed for equal-raster compact hierarchy, exact copy,
responsive placement, and frontpage recovery; persisted screenshot-artifact
evidence remains unavailable

## Store main-route not-found boundary

Source truth paths:

- Pinned Medusa DTC source at commit
  `19e8a6fbefea5a385e9502409908bfbebbecf526`:
  `/tmp/medusa-dtc-19e8a6f/apps/storefront/src/app/[countryCode]/(main)/layout.tsx`,
  `/tmp/medusa-dtc-19e8a6f/apps/storefront/src/app/[countryCode]/(main)/not-found.tsx`,
  and the product, collection, and category route pages that call Next.js
  `notFound()`.
- Live source: `https://next.medusajs.com/dk/products/does-not-exist`.

Implementation URL:
`http://127.0.0.1:13001/products/does-not-exist`.

The initial source and implementation comparison used equal `1280 x 720` CSS
viewports. A local `390 x 844` compact capture then verified the responsive
boundary. The remote Medusa tab did not accept that temporary compact override,
so no matched compact raster is claimed. Captures remain current-run session
evidence rather than persisted filesystem screenshot artifacts.

**Source and behavior findings**

- Medusa's missing product keeps the main navigation and footer around the same
  generic 404 message used at the root. The original local route instead showed
  a generic API retry error, omitted the footer, and did not distinguish a 404
  from a transient failure.
- A typed `ProductDetailStatus.missing` now maps only an HTTP 404 to the
  source-shaped boundary. Other failures retain their retry state.
- Missing product, collection, and category states render inside the existing
  `StoreScaffold`, preserve the requested URL, and share one main-route 404 body
  followed by the API-backed Store footer. Unknown root URLs continue to use
  the intentionally bare root boundary.
- The local free-shipping popup was dismissed before the final compact capture.
  Its presence is real cart/rule state, while the live Medusa cart exposes no
  equivalent conditional-price popup.

**Interaction evidence**

- Activating `Go to frontpage` navigated the local release build from the
  missing-product URL to `/`; browser Back returned to the same missing-product
  URL and restored the source-shaped boundary.
- Both settled tabs reported zero browser warnings or errors.

**Validation**

- The Store release Web build succeeded and the final route was recaptured.
- All 140 Store tests pass, including a real server round trip proving an
  unknown product enters the missing state; Flutter analysis reports no issue.
- Existing collection and category integration coverage proves unknown taxonomy
  enters the same missing lifecycle.
- Dust reports all 54 Store outputs clean. Dust i18n checks 688 translations
  with zero errors; its 15 warnings remain the existing stale/equal-fallback
  inventory outside this slice.
- Handwritten formatting, file-size, response-boundary, project-structure, and
  diff whitespace checks pass. No widget test was added.

Store main-route not-found result: passed for desktop source structure, typed
404 behavior, URL preservation, responsive local layout, footer ownership, and
frontpage recovery; a matched compact source raster remains unavailable

## Current Medusa DTC source pin

Upstream truth: `medusajs/dtc-starter` `main` resolved to
`bd2441acc18359533758fbf4db5bc80129055d2e` on 2026-09-15. The local current
source worktree is `/tmp/medusa-dtc-bd2441a`.

The previous parity pin was
`19e8a6fbefea5a385e9502409908bfbebbecf526`. A Git tree comparison from that
revision to current `main` changes five files only:

- `apps/backend/package.json`;
- `apps/storefront/package.json`;
- `apps/storefront/tsconfig.tsbuildinfo`;
- root `package.json`; and
- `pnpm-lock.yaml`.

No file under `apps/storefront/src` changed. The Store dependency revision
advances Medusa packages and `@medusajs/ui-preset` from 2.20.1 to 2.21.0 and
Next.js from 15.5.21 to 15.5.24.

The published UI preset archives for 2.20.1 and 2.21.0 were unpacked and
compared recursively. Only `CHANGELOG.md`, `package.json`, and Turbo build-log
metadata differ; shipped theme tokens and component files are identical.
Existing code-to-layout evidence therefore applies to current Medusa `main`.
Future source inspections use the refreshed worktree and 2.21.0 token authority.

Current Medusa DTC source-pin result: passed; storefront source and rendered
token inputs have no material drift from the completed comparisons

## Store checkout not-found boundary

Source truth paths at current Medusa DTC commit
`bd2441acc18359533758fbf4db5bc80129055d2e`:

- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/app/[countryCode]/(checkout)/layout.tsx`;
- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/app/[countryCode]/(checkout)/checkout/page.tsx`;
- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/app/[countryCode]/(checkout)/not-found.tsx`.

Live source shell: `https://next.medusajs.com/dk/checkout`.

Fresh-session implementation URL: `http://localhost:13001/checkout`. The
alternate local hostname isolates cart storage without deleting the existing
`127.0.0.1` QA cart; both origins serve the same release Web bundle.

**Source and behavior findings**

- Medusa keeps the checkout-only Back/brand header and bottom attribution around
  its generic 404 body when no cart exists. The original local guard redirected
  the missing capability to `/cart`, losing both the URL and checkout boundary.
- `CheckoutGuard` still restores cart state before route activation. A missing
  capability now proceeds to the checkout page so it can render the source 404
  at `/checkout`; a known valid-but-empty cart continues to return to `/cart`
  rather than entering an unusable payment flow.
- The shared checkout attribution was extracted into a concrete widget and is
  reused by successful and not-found checkout bodies. No method returns a
  Widget.
- Desktop local rendering preserves `BACK TO SHOPPING CART`, centered `MORROW`,
  the source-exact generic 404 hierarchy, and `Powered by dust` below the
  viewport-height body. At `390 x 844`, the header switches to source-shaped
  `BACK` while retaining the same centered content without overflow.

**Interaction evidence**

- The header Back action navigated the fresh session from `/checkout` to the
  empty `/cart` route. Browser Back restored `/checkout` and the same 404 state.
- `Go to frontpage` changed the route to `/`. The alternate hostname is not in
  the API's production-shaped CORS allowlist, so catalogue loading on that QA
  origin is not claimed; frontpage recovery on the allowed `127.0.0.1` origin
  was already verified in the root and main-route 404 slices.
- The settled live checkout shell and a new local checkout-404 tab each reported
  zero browser warnings or errors.

**Evidence limits**

- The live Medusa browser session already owns a populated cart, so its checkout
  URL renders the form rather than the no-cart boundary. Clearing that remote
  cart was not required or performed. The live checkout shell and live generic
  404 body were therefore verified separately against their current source
  composition; a same-state full-page raster is not claimed.
- Screenshots remain current-run session evidence rather than persisted
  filesystem artifacts.

**Validation**

- The Store release Web build succeeded and the fresh-session route was
  recaptured at desktop and compact sizes.
- All 141 Store tests pass. Dedicated non-widget route-guard tests prove both
  missing-cart URL preservation and valid empty-cart rejection; Flutter analysis
  reports no issue.
- Dust reports all 54 Store outputs clean. Dust i18n checks 688 translations
  with zero errors; its 15 warnings remain the existing stale/equal-fallback
  inventory outside this slice.
- Handwritten formatting, file-size, response-boundary, project-structure, and
  diff whitespace checks pass. No widget test was added.

Store checkout not-found result: passed for source composition, route-level
restoration, URL preservation, empty-cart safety, desktop and compact local
rendering, Back navigation, and browser-log cleanliness; a same-state live
Medusa no-cart raster remains unavailable

## Store checkout Delivery state

Source truth at current Medusa DTC commit
`bd2441acc18359533758fbf4db5bc80129055d2e`:

- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/modules/checkout/components/shipping/index.tsx`;
- live source checkout: `https://next.medusajs.com/dk/checkout`; and
- implementation checkout: `http://127.0.0.1:13001/checkout?step=delivery`.

**Source and behavior findings**

- Medusa renders Shipping method choices as one mutually exclusive radio group.
  Each row uses 32px horizontal and 16px vertical padding, an 8px radius, a
  16px radio-to-label gap, and 8px between choices. Selection changes the row
  to the interactive border; calculated choices without a price are disabled.
- The local release build uses the same row geometry and keeps price and
  eligibility server-owned. A real address save exposed Free shipping,
  Standard shipping and Express shipping. Free shipping was correctly disabled
  because the cart did not satisfy its item-total rule.
- The first semantics pass exposed the choices as buttons with `aria-current`.
  The focused correction now exposes radio-button roles, one checked value,
  disabled state, and a mutually exclusive group. The visible row remains a
  concrete widget; no private method returns a Widget.
- Local copy retains the grammatically correct “How would you like your order
  delivered” instead of reproducing the source typo “you order”. This is a
  deliberate production-copy correction, not an accidental visual divergence.

**Interaction evidence**

- Selecting Standard shipping changed authoritative Shipping to USD 5.00, Tax
  to USD 3.50 and Total to USD 38.50. Continue to payment advanced to Payment,
  where the collapsed Delivery summary retained Standard shipping at USD 5.00.
- Returning to Delivery retained the selected option. Selecting Express then
  changed Shipping to USD 15.00, Tax to USD 4.50 and Total to USD 49.50.
- Browser accessibility reported Free shipping disabled and unchecked,
  Standard unchecked, and Express checked. At `390 x 844`, the same selected,
  disabled and unchecked states remained present with the compact Back label,
  ordered checkout sections, totals and attribution; no layout overflow was
  observed.

**Evidence limits**

- The current live Medusa checkout rendered its checkout shell and populated
  cart, but its address content remained in a loading state. No remote address
  or cart mutation was performed, so a same-state Delivery raster is not
  claimed. The source implementation and local rendered state were compared
  separately.
- Medusa source contains pickup-option handling, but neither its live checkout
  data nor the Dust backend exposes a matching pickup model. Pickup parity
  remains open rather than being represented as a display-only option.
- Screenshots remain current-run browser evidence instead of persisted
  filesystem artifacts.

**Validation**

- All 141 Store tests pass and Flutter analysis reports no issue.
- Dust reports all 54 Store outputs clean. Dust i18n checks 688 translations
  with zero errors; its 15 warnings remain the existing stale/equal-fallback
  inventory outside this slice.
- Release Web rebuild, handwritten formatting, file-size, response-boundary,
  project-structure and diff-whitespace checks pass. No widget test was added.

Store checkout Delivery result: passed for current source-code composition,
real API-backed eligibility and selection, recalculated totals, payment
progression, restored choice state, radio accessibility semantics, and desktop
and compact local rendering; same-state live Medusa and pickup parity remain
open

## Store checkout Payment state

Source truth at current Medusa DTC commit
`bd2441acc18359533758fbf4db5bc80129055d2e`:

- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/modules/checkout/components/payment/index.tsx`;
- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/modules/checkout/components/payment-container/index.tsx`;
- live source checkout: `https://next.medusajs.com/dk/checkout`; and
- implementation checkout: `http://127.0.0.1:13001/checkout?step=payment`.

**Source and behavior findings**

- Medusa renders available providers as one Headless UI radio group. Each
  provider row uses 32px horizontal and 16px vertical padding, an 8px radius,
  8px bottom spacing, a 16px radio-to-title gap, and a provider icon at the
  opposite edge. Selection changes only the interactive border and radio.
- Dust discovers providers through the cart region API and retains selection in
  the server-owned payment session. The initial local Manual Payment option was
  exposed as a generic button even though its visual radio state matched the
  source.
- The focused correction extracts a concrete payment-choice widget and exposes
  checked state plus mutual exclusion. Its accessibility label uses the same
  localized provider-title resolver as visible copy, so an internal provider id
  does not replace the customer-facing name.
- Medusa's manual-payment development hint is intentionally absent from the
  production-shaped local release build. It is a test instruction guarded by
  `NODE_ENV === "development"`, not customer checkout content.

**Interaction evidence**

- Before selection, browser accessibility reported Manual Payment as an
  unchecked radio and Continue to review as disabled. Selecting it performed
  the real server mutation, changed the radio value to checked, and enabled the
  progression action.
- Continue to review preserved Manual Payment in the collapsed two-column
  summary with Payment method, Payment details, the credit-card icon, and
  “Another step will appear”, matching the source composition.
- Fresh document navigation to `?step=payment` restored the checked radio from
  the cart payment session. The keyboard shortcut left the Flutter document
  and semantic node identifiers unchanged, while the browser automation
  reload helper returned its original launch URL; neither was treated as
  reload evidence.
- At `390 x 844`, Payment uses the compact Back label, keeps the full-width
  provider row and ordered checkout/cart sections, and renders without
  horizontal overflow. The settled final build reports no browser warnings or
  errors.

**Evidence limits**

- The current live Medusa checkout continues to show its checkout shell and
  populated cart while its address content remains loading. No remote address,
  shipping or payment mutation was performed, so a same-state Payment raster is
  not claimed; current source composition and local rendered behavior were
  verified separately.
- The current DTC backend seed creates a shipping fulfillment set with Standard
  and Express shipping only. Its conditional pickup UI has no seeded pickup
  fulfillment set, so inventing one in Dust is not required for the reachable
  reference flow and remains a separate capability.
- Screenshots remain current-run browser evidence instead of persisted
  filesystem artifacts.

**Validation**

- All 141 Store tests pass and Flutter analysis reports no issue.
- Dust reports all 54 Store outputs clean. Dust i18n checks 688 translations
  with zero errors; its 15 warnings remain the existing stale/equal-fallback
  inventory outside this slice.
- The final release Web rebuild, handwritten formatting, file-size,
  response-boundary, project-structure and diff-whitespace checks pass. No
  widget test was added.

Store checkout Payment result: passed for current source-code composition,
server-retained provider selection, disabled/enabled progression, checked radio
semantics, Review summary, fresh-document restoration, compact rendering and
browser-log cleanliness; a same-state live Medusa raster remains unavailable

## Store checkout large actions

Source truth at current Medusa DTC commit
`bd2441acc18359533758fbf4db5bc80129055d2e`:

- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/modules/checkout/components/review/index.tsx`;
- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/modules/checkout/components/payment-button/index.tsx`; and
- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/modules/common/components/ui/index.tsx`.

**Source and implementation findings**

- Medusa's shared large primary button uses `h-12 px-6 text-lg`: 48px height,
  24px horizontal padding and 18px type, with a 6px radius, black enabled
  surface and gray-800 hover surface.
- The local Review action inherited the 40px Material theme button height. An
  outer 48px constraint on Payment could still leave a 40px semantic button,
  so a wrapper alone was not an equivalent implementation.
- One concrete checkout action now owns the large-button geometry, progress,
  disabled state, hover treatment and button semantics. Address, Delivery,
  Payment and Review reuse it; no method returns a `Widget`.
- Localized labels remain resolved from literal Dust i18n keys at each caller.
  This keeps extraction deterministic and avoids hiding keys behind a dynamic
  component parameter.

**Rendered evidence**

- Fresh release-document measurements report Place order at 48px by 141.64px,
  Continue to review at 48px by 200.42px, Continue to payment at 48px by
  218.58px, and Continue to delivery at 48px by 210.76px.
- Review at `390 x 844` keeps the source's compact single-column checkout
  composition without horizontal overflow. The settled document reports no
  browser warnings or errors.
- The keyboard reload shortcut did not replace the Flutter document: semantic
  node identifiers remained unchanged. The browser helper instead restored its
  original launch URL. Only direct fresh document navigation was used for the
  measurements and retained-state evidence above.

**Evidence limits**

- The live Medusa checkout remained on its loading address content, so a
  same-state remote Review or Payment raster is not claimed. Source code and
  local rendered behavior were compared separately.
- The current DTC seed exposes Standard and Express shipping only. Its dormant
  pickup branch is not a reachable reference capability and was not invented
  in Dust for this visual correction.

**Validation**

- All 141 Store tests pass and Flutter analysis reports no issue.
- Dust reports all 54 Store outputs clean. Dust i18n checks 688 translations
  with zero errors; its 15 warnings are the existing stale/equal-fallback
  inventory outside this slice.
- The release Web build, handwritten formatting, file-size, response-boundary,
  project-structure and diff-whitespace checks pass. No widget test was added.

Store checkout large actions result: passed for shared source geometry,
fresh-document measurements, compact rendering and browser-log cleanliness;
same-state live Medusa rendering remains unavailable

## Store order confirmation help links

Source truth at current Medusa DTC commit
`bd2441acc18359533758fbf4db5bc80129055d2e`:

- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/app/[countryCode]/(main)/order/[id]/confirmed/page.tsx`;
- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/modules/order/templates/order-completed-template.tsx`; and
- `/tmp/medusa-dtc-bd2441a/apps/storefront/src/modules/order/components/help/index.tsx`.

**Source and implementation findings**

- The source confirmation template renders the full order receipt, then a
  `Need help?` block with two links: `Contact` and `Returns & Exchanges`. Both
  links navigate to `/contact`.
- The local confirmation already restored the source receipt hierarchy after a
  real checkout: success heading, confirmation email, order date, order number,
  Summary, line item, totals, Delivery, Payment and footer. The focused gap was
  the second help link, because Morrow rendered only `Contact`.
- The correction keeps the existing contact route and adds the missing
  `Returns & Exchanges` link beside `Contact`. Both actions route to
  `/contact?orderReference=4` in the verified order, preserving Morrow's useful
  visible order-number prefill.

**Browser evidence**

- A release-mode local checkout placed order `4` from the Review step with a
  real cart: two black medium T-shirts, `USD 30.00` subtotal, `USD 15.00`
  Express shipping, `USD 4.50` tax and `USD 49.50` total.
- Desktop confirmation at `13001` rendered the source section order and zero
  cart count after checkout.
- Compact confirmation at `390 x 844` rendered both accessible links under
  `Need help?`: `Contact` and `Returns & Exchanges`. It had no horizontal
  overflow in the visible confirmation and footer states.
- Selecting `Returns & Exchanges` navigated to
  `/contact?orderReference=4`; the contact form showed order number `4`
  prefilled. Browser Back returned to a fresh confirmation document with both
  links still present.
- The settled browser pass reported no warning or error logs.

**Evidence limits**

- The public Medusa checkout still did not reach a same-state completed order,
  so this pass compares pinned source structure plus local browser behavior,
  not a remote same-order raster.
- The source `/contact` destination is separate from the Morrow customer-service
  route; retaining the order-reference query is a local product improvement
  over the bare source link.

**Validation**

- All 141 Store tests pass and Flutter analysis reports no issue.
- Dust reports all 54 Store outputs clean. Dust i18n checks 688 translations
  with zero errors; its 15 warnings are the existing stale/equal-fallback
  inventory outside this slice.
- Handwritten formatting, file-size, response-boundary, project-structure and
  diff-whitespace checks pass. No widget test was added.

Store order confirmation help links result: passed for current source-code
composition, compact browser behavior, contact prefill and browser-log
cleanliness; same-state live Medusa confirmation remains unavailable

## Store authenticated order history and detail

This slice closes the browser-evidence gap for the authenticated order list and
order detail routes. It uses a fresh PostgreSQL database, the current SQLx
migrations and the opt-in development seed; the Store ran on `13001` against
the local API on `3880`.

**Browser evidence**

- A synthetic QA customer signed in through `/account` and the account
  overview showed the server-owned customer identity.
- `/account/orders` rendered the source-shaped order history with order `#1`,
  the `Wed Nov 4 2026` date, `USD 25.58` total, one item and the transfer
  request surface.
- `See details` opened the opaque-id route
  `/account/orders/details/:id`. The detail page rendered the receipt email,
  order date/number, `Not fulfilled` status, `Captured` payment, line item,
  Delivery, Shipping Address, Contact, Method, Order Summary and both `Contact`
  and `Returns & Exchanges` actions.
- The order was created through the real Store checkout API, manually
  authorized and captured, so the page was not backed by a static fixture.

**Evidence limits**

- This proves local authenticated route composition and ownership-backed data.
  A same-state authenticated Medusa raster remains unavailable, so pixel parity
  is still pending.

**Validation**

- `flutter test apps/commerce_app/test/account/account_orders_view_model_test.dart apps/commerce_app/test/account/account_order_detail_view_model_test.dart apps/commerce_app/test/account/account_route_guard_test.dart` passed: 12 tests.
- No widget test was added.

Store authenticated order history/detail result: functional route and local
browser composition passed; authenticated Medusa visual comparison remains open

## Store authenticated profile password editor

This slice closes the functional gap where the existing password-rotation
editor was implemented but not mounted on `/account/profile`.

**Browser evidence**

- A fresh PostgreSQL database, full SQLx migration set and opt-in development
  seed ran behind API `3878`; the Store ran on `13001`.
- A QA customer signed in successfully through the Store account route. The
  authenticated profile rendered the `PASSWORD` row with the source copy, and
  `Edit` opened `Old password`, `New password`, `Confirm password`, `Cancel`
  and `Save changes` controls.
- The editor was inspected without submitting a password change, so no
  credential mutation was performed during browser QA.

**Evidence limits**

- This proves the route wiring and local rendered composition. A same-state
  authenticated Medusa raster remains unavailable, so pixel parity is still
  pending.

**Validation**

- `dart analyze apps/commerce_app` passed with no issues.
- The three account ViewModel/guard suites passed with Flutter: 13 tests.
- `flutter build web --release` passed.
- No widget test was added.

Store authenticated profile password editor result: functional route and local
browser composition passed; authenticated Medusa visual comparison remains open

## Store authenticated saved-address checkout

This slice verifies the saved-address path end to end against the local Store
and API, including the server-owned checkout state rather than only the form
presentation.

**Browser evidence**

- A QA customer signed in through the Store and received a saved address from
  the real customer-address API.
- The account address book rendered the saved card and its Edit/Remove actions.
  The card now has an explicit 220px height because its action row uses a
  `Spacer`; this keeps the column finite inside the address-book scroll view
  and removes the Flutter unbounded-constraints assertion/visual overlap.
- Checkout opened the saved-address selector. Selecting the saved address
  copied the server-owned name, street, city, postal code, country and phone
  into the checkout fields.
- Continuing to Delivery persisted `cart_addresses` in PostgreSQL. The direct
  `?step=delivery` route restored the address and showed Standard, Express and
  Free delivery options.
- Standard shipping and Manual Payment were selected, and the flow reached
  `http://127.0.0.1:13001/checkout?step=review`. A hard reload retained the
  review route and produced no new browser warning or error logs.

**Evidence limits**

- A same-state authenticated Medusa checkout raster remains unavailable, so
  this pass proves local route/data behavior and source-shaped composition,
  not final pixel parity.

**Validation**

- The focused saved-address, address-book and checkout ViewModel tests passed:
  5 tests.
- Scoped account/checkout analysis passed with no issues.
- No widget test was added.

Store authenticated saved-address checkout result: server-backed address
selection, persistence, delivery/payment progression and reload passed; the
authenticated Medusa visual comparison remains open

## Store checkout deep-link guard hardening

The pinned Medusa Review step only becomes actionable when the server cart has
the shipping address, shipping method and payment collection required by the
previous steps. The local route previously inferred those gates from the
checkout draft, which could become stale after another cart mutation or a
direct deep link.

The guard now reads the server-owned cart projection for all three gates. A
stale `?step=review` therefore falls back to Address, Delivery or Payment
without exposing the Place order action against incomplete cart state.

Validation: the checkout route-guard and ViewModel suites passed (4 tests),
Flutter analysis passed, and the Store Dust check reported 194 clean generated
files. No widget test was added.

Store checkout deep-link guard result: server-authoritative step gating passed;
same-state Medusa visual comparison remains open

## Store seeded catalogue, product and cart smoke

This slice verifies the public Store's first customer path against a fresh
PostgreSQL database, the complete SQLx migration set and the opt-in development
seed. The API ran on `3878` and the Store ran on `13001`.

**Browser evidence**

- The home route rendered the Morrow shell, Featured rail and seeded product
  cards after the browser's Flutter accessibility bridge was enabled.
- `/collections/featured` rendered the source-shaped sort controls, 12 product
  cards and the Morrow footer taxonomy.
- `/products/classic-white-tee` rendered the image, title, description, price,
  information accordions and Add to cart control.
- Add to cart incremented the header badge to `Cart (1)`. `/cart` then rendered
  the Classic White Tee line, quantity control, USD 18.25 price and checkout
  summary. No account or payment mutation was submitted.

**Validation**

- The production-entrypoint test passed against isolated PostgreSQL: startup,
  21-product seed, `/health`, and clean restart.
- The full Store Flutter suite passed: 168 tests.
- Flutter analysis passed with no issues; Dust checks reported 194 clean Store
  outputs and 166 clean server outputs.
- The browser harness's initial white canvas was its `Enable accessibility`
  bridge state, not a Store/API failure; the enabled semantics tree and render
  matched the expected routes above.
- No widget test was added.

Store seeded catalogue/product/cart result: local public vertical slice passed;
same-state Medusa visual comparison remains open

final result: blocked
