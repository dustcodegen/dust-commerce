# dust-commerce

A headless commerce backend and storefront, written in Dart end to end, built to
show what [Dust](https://github.com/dustcodegen/dust) generates in a real
application rather than in a snippet.

## What this is a clone of

The domain model follows **[Medusa](https://github.com/medusajs/medusa)** — the
MIT-licensed headless commerce platform written in TypeScript. Medusa was chosen
because its model is the one most commerce projects converge on, it is widely
used, and its licence puts no constraints on studying it.

**This is a source-guided reimplementation, not a runtime port.** The Flutter
storefront translates the MIT-licensed Medusa DTC Starter screen structure and
interaction flow into Dust patterns; it does not embed React, Next.js, or the
Medusa SDK. The backend remains an independent Dart and PostgreSQL implementation.
See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the pinned source and
attribution.

This project is not affiliated with, endorsed by, or derived from Medusa.

[docs/comparison.md](docs/comparison.md) sets the two side by side against a
pinned Medusa source commit. This project implements tested storefront slices
and isolated admin identity and product-management slices. It is not yet a
Medusa replacement and has no workflow engine or plugin platform.

### What is modelled

| Concept | Follows Medusa in | Deliberately simplified |
| :--- | :--- | :--- |
| `Product` / `ProductVariant` | variants carry price and stock, not the product | one simple option matrix |
| `Money` | integer minor units plus currency, never a float | single currency per region |
| `Cart` / `LineItem` | line items snapshot unit price when added | one shipping method and promotion per cart |
| `Order` | an immutable snapshot of a cart at checkout | manual refunds only; no external refund, label or exchange workflow |
| `Region` | currency and tax rate scope | no multi-warehouse |
| `Customer` / `AuthIdentity` | customer data is separate from provider credentials | email/password only; no reset, MFA, or OAuth |
| `PaymentCollection` | payment state belongs to the order | manual provider only; no card data |

Prices are integer minor units throughout. Storing money in a floating point
type is the most common bug in commerce code and it is not reproduced here.

## Why it exists

Dust generates Dart from annotations. This repository is the case where that
matters most: **one set of model definitions, generated in both directions.**
The server decodes exactly what each generated HTTP client encodes. Customer
contracts live in `commerce_shared`; merchant-only contracts live in
`commerce_admin_shared`, so the storefront cannot accidentally import an admin
API type. Change a field once and its two ends move together, or fail together.

## What is generated, and what is not

Being precise about this is part of the point of the repository.

| Layer | Dust generates | Written by hand |
| :--- | :--- | :--- |
| shared contracts | data classes, JSON, validation | the model definitions |
| `commerce_server` | row mapping, DAOs, static SQL checking | routing, handlers, extractors |
| Flutter apps | routing, view models, i18n, HTTP clients | widgets |

There is no server code generator in Dust today. Handlers are written against
`dust_server`'s API directly, and that is not a workaround — the runtime is
designed to be written against.

Generated `.g.dart` files are ignored. Local and CI builds run
`./scripts/generate.sh` before analysis or tests; CI validates every normal,
database, and i18n output before compiling its consumers.

## Layout

```
packages/commerce_shared         customer storefront contracts
packages/commerce_admin_shared   merchant-only admin contracts
packages/commerce_server         dust_server API on PostgreSQL
apps/commerce_app                Flutter storefront (port 13001)
apps/admin_app                   Flutter merchant admin (port 13002)
```

[docs/architecture](docs/architecture/) traces one request from widget to row.
[docs/admin-parity.md](docs/admin-parity.md) maps the isolated merchant program
to its Medusa source areas and GitHub delivery issues.

## Running it

Requires the Dust CLI at 0.3.1 or newer:

```bash
dust --version
```

```bash
flutter pub get
./scripts/generate.sh
```

Start a local API with the deterministic development catalogue:

```bash
DATABASE_URL='postgres://dust:dust@127.0.0.1:5432/dust_commerce?sslmode=disable' \
  sqlx migrate run --source packages/commerce_server/migrations
COMMERCE_SEED=true \
  COMMERCE_ALLOWED_ORIGINS=http://127.0.0.1:13001,http://127.0.0.1:13002 \
  COMMERCE_DATABASE_URL='postgres://dust:dust@127.0.0.1:5432/dust_commerce?sslmode=disable' \
  dart run packages/commerce_server/bin/server.dart
```

The seed is opt-in and idempotent. Production startup never creates merchant or
customer records. Bind address, port, database URL, and browser origins are
configured with `COMMERCE_BIND`, `COMMERCE_PORT`, `COMMERCE_DATABASE_URL`, and
comma-separated `COMMERCE_ALLOWED_ORIGINS`. The API defaults to port `3878`
(`DUST` on a telephone keypad); override it explicitly for each deployment.
Product images default to `.data/media`. Set `COMMERCE_MEDIA_PATH` to a durable
single-node volume and `COMMERCE_PUBLIC_BASE_URL` to the public API origin that
owns `/uploads`. Multi-node deployments should replace this adapter with shared
object storage; local disk is not presented as a CDN.

Order-transfer requests remain unavailable with `503` until outbound email is
configured. Set `COMMERCE_SMTP_HOST`, `COMMERCE_SMTP_FROM`, and the public
`COMMERCE_STOREFRONT_URL`; optional settings are `COMMERCE_SMTP_PORT` (default
`587`), `COMMERCE_SMTP_SSL` (default `false`), `COMMERCE_SMTP_FROM_NAME`, and
`COMMERCE_SMTP_TIMEOUT_SECONDS`. Username and password must be supplied
together as `COMMERCE_SMTP_USERNAME` and `COMMERCE_SMTP_PASSWORD`. With SSL
disabled the client requires STARTTLS rather than permitting plaintext. Keep
all SMTP credentials on the server; the storefront URL is used only to build
the emailed decision link.

To reset development data safely, stop the API and use a disposable PostgreSQL
database. Keep the old database available as a backup until the replacement
stack has started and passed `/health`.

In a second terminal, start the Flutter web storefront:

```bash
cd apps/commerce_app
flutter run -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port 13001 \
  --dart-define=API_BASE_URL=http://127.0.0.1:3878
```

Create the first admin through the non-public bootstrap command. It accepts the
password only through the environment, never as a command argument; inject the
secret through the deployment environment in production.

```bash
COMMERCE_ADMIN_EMAIL=owner@example.com \
  COMMERCE_ADMIN_PASSWORD='replace-with-a-long-secret' \
  COMMERCE_DATABASE_URL='postgres://dust:dust@127.0.0.1:5432/dust_commerce?sslmode=disable' \
  dart run packages/commerce_server/bin/create_admin.dart
```

Start the separate merchant app in a third terminal:

```bash
cd apps/admin_app
flutter run -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port 13002 \
  --dart-define=API_BASE_URL=http://127.0.0.1:3878
```

The repository-owned development ports are `13001` for the storefront,
`13002` for admin, and `3878` for the API. None uses a framework default.

## Delivery

Every successful CI run on `main` packages the Store, Admin, and Linux API as
downloadable GitHub Actions artifacts. Set the repository variable
`PRODUCTION_API_BASE_URL` to the deployed API origin before merging; release
web builds reject the local development default. Artifact creation is
continuous delivery only: deployment remains the hosting platform's job.

Then the same checks CI runs:

```bash
./scripts/format.sh --check && ./scripts/check_file_size.sh
```

Run one package's generator, analyzer and correct Dart/Flutter test runner from
the repository root with:

```bash
./scripts/verify_package.sh apps/admin_app
```

The process-level smoke starts the real server entrypoint against a temporary
database, waits for health, verifies the twenty-product public catalogue,
shuts it down
gracefully, and restarts it against the same database to prove seeding remains
idempotent:

```bash
dart test packages/commerce_server/test/server_entrypoint_test.dart
```

### Database migrations

The server uses PostgreSQL. UTC instants are stored in native `TIMESTAMPTZ`
columns with database defaults and update triggers; application code receives
UTC `DateTime` values.

The baseline is intentionally one final table per timestamped reversible SQLx
pair. Create another pair with:

```bash
sqlx migrate add <table_name> -r --timestamp \
  --source packages/commerce_server/migrations
```

This is a migration-history reset from the former `0001`-`0005` files. Do not
point it at a database that already recorded those versions: rebuild a backed-up
pre-release database, or ship a separately designed bridge migration instead.

Use SQLx for explicit forward/reverse operation:

```bash
DATABASE_URL='postgres://dust:dust@127.0.0.1:5432/dust_commerce?sslmode=disable' sqlx migrate run \
  --source packages/commerce_server/migrations
DATABASE_URL='postgres://dust:dust@127.0.0.1:5432/dust_commerce?sslmode=disable' sqlx migrate revert \
  --source packages/commerce_server/migrations
```

Dust embeds the same reversible migrations for application startup; SQLx remains
the operator tool for explicit forward/reverse checks. The server applies
pending migrations before accepting traffic. The baseline contains no appended
`ALTER TABLE` steps: each table's up file is its complete definition.

## Licence

MIT. See [LICENSE](LICENSE).
