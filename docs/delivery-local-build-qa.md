# Local delivery build QA

## Scope

This is a packaging check, not a production deployment. The build uses the
non-routable placeholder origin `https://api.example.invalid` so no artifact
can accidentally point at a real service.

## Evidence

On 2026-11-05, from `main` at `8f2ce096`, these release commands completed
successfully:

```bash
(cd apps/commerce_app && flutter build web --release --no-pub \
  --dart-define=API_BASE_URL=https://api.example.invalid)
(cd apps/admin_app && flutter build web --release --no-pub \
  --dart-define=API_BASE_URL=https://api.example.invalid)
dart compile exe packages/commerce_server/bin/server.dart \
  -o /tmp/dust-commerce-server
```

Both Flutter commands produced `build/web/index.html`; the Dart command
produced an executable Linux API bundle at
`/tmp/dust-commerce-server-current`. Flutter's release compiler also
completed its WebAssembly dry run for both applications.

The latest observed post-merge Delivery run `42056675837` correctly stopped
before building artifacts because the repository variable
`PRODUCTION_API_BASE_URL` is not configured. A real absolute HTTP(S)
deployment origin is still required before a release artifact can be
considered production-ready; the fail-closed workflow guard remains
intentional.

## Current merged revision

On 2026-11-06, merged `main` revision `3eade5bbe425c572044808dc4f7e56cc01d9963e`
also passed local release packaging with the repository API origin:

```bash
(cd apps/commerce_app && flutter build web --release \
  --dart-define=API_BASE_URL=http://127.0.0.1:3878 \
  --output=/tmp/dust-commerce-store-build)
(cd apps/admin_app && flutter build web --release \
  --dart-define=API_BASE_URL=http://127.0.0.1:3878 \
  --output=/tmp/dust-commerce-admin-build)
dart compile exe packages/commerce_server/bin/server.dart \
  -o /tmp/dust-commerce-server-3eade5bb
```

The Store and Admin builds completed with Flutter's WebAssembly dry run, and
the API executable was produced. Post-merge CI `42112098620` passed all
repository verification steps. Delivery `42114289109` still fails closed at
the production-origin check with `PRODUCTION_API_BASE_URL` unset; it does not
indicate an artifact compilation failure.
