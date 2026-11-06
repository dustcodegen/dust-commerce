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

## Fresh migration smoke

Validated 2026-11-06 against the current `feat/admin-promotion-create` branch
with a fresh PostgreSQL database (`dust_commerce_smoke`). SQLx applied all 65
committed migrations, including `20261104120000` (`shipping option
fulfillments`), without checksum or DDL errors. The Dust API listened on
`127.0.0.1:3878` and the Flutter Store on `127.0.0.1:13001`.

- `/` rendered the Morrow shell and `Powered by dust` attribution.
- `/store` loaded seeded products, search, sort choices, and color/size facets.
- `/products/t-shirt?v_id=var_tshirt_m_black` rendered the black M variant with
  price, stock state, and Add to cart.
- Add to cart changed the badge to `Cart (1)` and opened the cart preview with
  the T-shirt line, quantity 1, and `USD 15.00` subtotal.
- Go to cart rendered the line item, quantity control, promotion entry, taxes,
  total (`USD 16.50`), and Go to checkout action.

No order was placed. This is local functional evidence only; it does not claim
CI, deployment, or same-state raster parity with Medusa.

## Atomic form-add smoke

Validated 2026-11-06 on the same local stack after the storefront switched its
generated client and cart ViewModel to `POST /store/cart/add` with
`application/x-www-form-urlencoded` fields.

- `/products/t-shirt?v_id=var_tshirt_m_black` rendered the selected Black/M
  variant and enabled Add to cart.
- Add to cart completed without an intermediate empty-cart state; the header
  badge changed from `Cart (1)` to `Cart (2)`.
- The free-shipping progress amount changed from `USD 85.00` to `USD 70.00`,
  proving the refreshed server cart reached the shell.

No order was placed. This is local browser evidence only; no CI, remote push,
or merge was triggered.
