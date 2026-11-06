# Storefront verification QA

## Scope

This is the current repository-level verification for the customer storefront.
It covers Dust generation/checks, Flutter static analysis, and the package's
non-widget test suite. It does not claim a production deployment or a pixel
comparison against a live Medusa preview.

## Evidence

On 2026-11-06, from `feat/admin-promotion-create` revision `628d5689`, the repository-root contract
completed successfully:

```bash
./scripts/verify_package.sh apps/commerce_app
```

The run reported:

- Dust generated-output checks: clean
- Flutter analysis: no issues
- Flutter tests: 178 passed
- Widget tests: none added
- Exact `dust_test_*` databases: cleaned on verifier exit; `dust_commerce` retained

The verification is intentionally scoped to the storefront package. Server,
Admin, release-artifact, and browser evidence remain separate gates in their
respective QA records.
