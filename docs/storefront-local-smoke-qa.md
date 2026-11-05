# Storefront local smoke QA

Validated 2026-11-05 against the current `main` merge (`d2f2edc8`) with the
real Dust API on `127.0.0.1:3878`, PostgreSQL on `127.0.0.1:55433`, and the
Flutter Store on `127.0.0.1:13001`.

## Observed customer flow

- `/` rendered the Morrow shell, cart badge, featured products, free-shipping
  message, and the exact `Powered by dust` attribution.
- `/store?q=tee` retained the query in the URL and returned Classic White Tee,
  Heavyweight Black Tee, and Split Raglan Tee.
- `/products/heavyweight-black-tee` rendered the product image, price,
  description, information accordions, and Add to cart action.
- Add to cart changed the badge from `Cart (1)` to `Cart (2)` and opened the
  source-shaped cart preview with both lines and a USD 36.75 subtotal.
- `/cart` rendered both line items, quantity controls, remove actions, subtotal,
  tax, total (`USD 40.43`), promotion entry, and Go to checkout.
- Browser console inspection reported no errors or warnings during the flow.

The development database already contained one cart line before this run, so
the smoke intentionally did not claim a clean-cart starting state. No order was
placed. This is functional evidence; same-state Medusa raster comparison stays
tracked separately in the parity ledger.
