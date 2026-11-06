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

The latest observed post-merge Delivery run `42137645330` correctly stopped
before building artifacts because the repository variable
`PRODUCTION_API_BASE_URL` is not configured. A real absolute HTTP(S)
deployment origin is still required before a release artifact can be
considered production-ready; the fail-closed workflow guard remains
intentional.

## Current merged revision

On 2026-11-06, merged `main` revision `05b68cdd` passed the full post-merge
CI verification run `42136072971`. Generation, generated-output policy,
SQLx migration up/down checks, analysis, formatting, tests, file-size budget,
backend structure, and both Flutter post-checks all passed.

Delivery run `42137645330` reached the fail-closed
`Validate the production API origin` step and did not build or upload release
artifacts. The next release action is operational: set the GitHub repository
variable `PRODUCTION_API_BASE_URL` to the deployed absolute HTTP(S) API origin,
then rerun Delivery from a successful `main` CI run.

The earlier local packaging evidence remains valid for its recorded revision:

```bash
(cd apps/commerce_app && flutter build web --release --no-pub \
  --dart-define=API_BASE_URL=https://api.example.invalid)
(cd apps/admin_app && flutter build web --release --no-pub \
  --dart-define=API_BASE_URL=https://api.example.invalid)
dart compile exe packages/commerce_server/bin/server.dart \
  -o /tmp/dust-commerce-server
```

Those commands are local placeholder-origin packaging evidence, not a
production deployment claim.
