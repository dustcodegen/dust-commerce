# Correction pattern ledger

This ledger records mistakes that changed how the project should be built. It is
evidence for future rules, not a second rulebook. Enforced rules remain in
[`CONTRIBUTING.md`](../CONTRIBUTING.md).

## Promotion process

1. Record the concrete symptom and correction in the slice where it happened.
2. Put user-directed corrections below **User correction patterns** and
   agent-detected corrections below **Self-correction patterns**.
3. Update the existing row instead of adding a differently worded duplicate.
4. Mark a recurrence only when the same failure appears in another slice.
5. Promote a candidate when it prevents a real defect and is cheap to follow.
6. Prefer an automated check; document-only rules need a clear review signal.
7. Move promoted wording to `CONTRIBUTING.md` and keep the evidence here.

Status meanings: **observed** happened once, **repeated** happened more than
once, and **promoted** already has an enforced project rule.

A candidate is not a rule. Do not treat personal preference, a one-off compile
error, or an unverified suspicion as policy. The evidence must identify the
affected slice and the authoritative check that exposed or verified it.

## User correction patterns

| Status | Symptom | Durable candidate | Enforcement idea |
| :--- | :--- | :--- | :--- |
| promoted | A private method returned `Widget`, hiding composition and rebuild ownership. | Every UI subtree is a dedicated widget class; only framework `build` methods return widgets. | Scan handwritten Dart for private `Widget` or `List<Widget>` methods. |
| promoted | A service boundary could return `Result<Result<T, DomainFailure>, SqlxError>`. | One feature failure type crosses each boundary; map infrastructure failures before returning. | Search for nested `Result` signatures and test each error mapping. |
| repeated | Response types inherited database or domain models and could disclose new internal fields. | Store and Admin responses are standalone explicit allowlists. | Contract review checks inheritance and round-trip tests pin serialized keys. |
| repeated | SQL rows were mapped to an intermediate model and then converted again. | Use direct SQLx `FromRow` response projections when the query already selects the public allowlist. | Query tests compile and decode the exact response target. |
| repeated | Nullable UI state blurred “not loaded”, “missing”, and “failed”. | Use `Option` for state absence; keep nullable fields only at wire or SQL boundaries where null is data. | State review plus equality tests for idle, empty, and failed states. |
| repeated | Authorization was threaded through API methods or parsed in handlers. | Dio owns bearer attachment; protected routers use a route guard and handlers require the authenticated extractor. | Route tests cover missing, invalid, foreign, and owned credentials; API signatures contain no token. |
| repeated | Timestamps came from application clocks or were represented as strings in Dart. | SQLite owns UTC ISO-text timestamps; Dart contracts use `DateTime`. | Schema checks reject application timestamp parameters; serialization tests assert UTC instants. |
| repeated | Migration follow-ups patched a table with appended `ALTER TABLE` files. | For unreleased schema work, write a one-shot final table migration, one table per reversible migration. | Migration inventory check plus clean `sqlx migrate run` and `sqlx migrate revert` verification. |
| repeated | Password handling risked generic hashes or plaintext-shaped storage. | Hash passwords with Argon2id and store only self-describing PHC values. | Authentication tests cover fresh salt, verify, wrong secret, and no plaintext persistence. |
| promoted | Handwritten files grew by accumulating unrelated helpers. | Keep handwritten files within 180 code lines and split by responsibility. | `scripts/check_file_size.sh`; fail only newly introduced violations while legacy debt is reduced. |
| promoted | Generated `.g.dart` output was formatted or edited by hand and became stale. | Ignore generated Dart and rebuild it from annotated source. | Clean-checkout generation, `dust check`, `dust check --db`, and handwritten-only formatting. |
| repeated | Large feature branches mixed contracts, backend, UI, QA, and documentation. | Use short stacked branches and commits, one responsibility per slice. | Review each commit independently and keep its verification evidence scoped. |
| repeated | UI polish started before the capability worked, or screenshots substituted for source understanding. | Implement and test the vertical feature first; compare pinned component and locale source before rendered visual QA. | Parity docs name source commit, source paths and keys, functional evidence, and remaining rendered QA separately. |
| observed | Widget tests were added before the requested testing phase. | Do not add widget tests until that phase is explicitly opened; use unit, contract, and browser QA meanwhile. | Review test type in each slice. |
| repeated | Product identity drifted to an internal project name, attribution, or common development port. | Customer brand is Morrow, attribution is only `Powered by dust`, and Store/Admin/API use 13001/13002/3878. | Browser smoke assertions and configuration constants. |

## Self-correction patterns

| Status | Symptom | Durable candidate | Enforcement idea |
| :--- | :--- | :--- | :--- |
| observed | A weak-context patch placed an import at the end of a Dart file. | Patch imports and structural edits with anchored context, then inspect the changed file before formatting. | Run analyzer, formatter, `git diff --check`, and inspect head/tail after structural patches. |
| promoted | A Dust command was run from a package directory while its `--root` was repository-relative, so workspace discovery failed. | Run repository-relative Dust commands from the repository root. | `scripts/verify_package.sh` rejects any other working directory before Dust runs. |
| promoted | Package-prefixed paths were passed to `dart format` from inside that package; it found no files but the surrounding command still reached a successful analyzer exit. | Resolve paths against the command working directory and treat “formatted no files” as a failed preflight. | `scripts/verify_package.sh` resolves from the root and rejects an empty handwritten-source set. |
| observed | `dart analyze --no-fatal-infos` was copied from another analyzer workflow, but this SDK does not support that option. | Use the repository's plain `dart analyze` or `flutter analyze --no-pub` commands without guessed flags. | Keep package-specific analyzer commands in one checked script. |
| observed | A strict `JsonExtractable` unknown-key test expected `400`, but Dust Server classifies a syntactically valid body it cannot construct as `422`. | Pin tests to the extractor's documented rejection classes: media type `415`, syntax `400`, construction or validation `422`. | Add one shared extractor-status contract test and reuse its expectations. |
| observed | Generated SerDe ignored an unknown `password` key, so a security-sensitive Admin command accepted more input than its type declared. | Wrap security-sensitive JSON commands in an explicit wire-field allowlist and reject unknown keys before validation or persistence. | Integration tests send one secret-shaped unknown key and assert `422` plus zero writes. |
| observed | A nullable SerDe field used `SerDeCodec<String?, String?>`, but generated code invokes the codec only for a present non-null payload and would not compile. | Type a nullable field's codec for the non-null payload; let generated null handling represent absence. | Build generated output and compile a consumer test covering null and present values. |
| observed | Omitting an explicit rename on the `phoneValue` backing field emitted `phone_value` instead of the public `phone` key. | Pin wire names whenever a nullable backing name differs from the public contract. | Round-trip tests assert the exact serialized key set, not only decoded values. |
| observed | Static analysis was clean while a generated SerDe consumer still failed during test compilation. | Analyzer success does not replace compiling generated consumers after every build. | Run a focused package test after generation before treating analyzer output as verification. |
| observed | Adding the refund-reason table made the exact migration inventory test fail at 60 versus its old 59 expectation. | Update the migration inventory contract in the same schema slice as every added or removed migration. | Derive the expected inventory from a reviewed manifest, then prove run, revert and re-run. |
| promoted | Tests were started with the wrong runner or from the workspace root, so Flutter lacked `dart:ui` or Dart found no root `test/` directory. | Run each suite from its owning package; use `flutter test --no-pub` for Flutter and `dart test` for pure Dart. | `scripts/verify_package.sh` selects both runner and working directory from `pubspec.yaml`. |
| observed | Preflight assumed a root `dust.yaml`, but the relevant configuration belonged to an application package. | Locate Dust configuration with `rg --files -g dust.yaml` before reading or invoking it. | Preflight prints the resolved configuration path. |
| repeated | `sqlx migrate run` was pointed at legacy QA data with absent or checksum-divergent SQLx history. | Production-style QA starts from a fresh SQLx database unless `_sqlx_migrations` exactly matches the binary. | Let startup and SQLx checks fail closed; create a new disposable QA database instead of bypassing or rewriting history. |
| observed | A QA script guessed a shipping option's field as `id` and selected a conditional free rate that the cart did not qualify for. | Read generated contracts or observed responses instead of guessing keys, then select data whose published rules are satisfied. | Assert required response keys and eligibility with `jq -e` before sending the next mutation. |
| observed | A long-running test handle expired during context compaction. | Missing process state is unknown, never a pass; rerun the exact authoritative check. | Final evidence must include a current exit code and test count. |
| observed | A security test froze the application clock to a historical date while SQLite generated the current audit timestamp, eventually violating `expires_at > created_at`. | Freeze only clocks fully owned by the test; when production compares an injected expiry with a database-owned timestamp, capture the current UTC wall clock and assert relative behavior. | Run time-sensitive suites after their original fixture date and keep database timestamp checks enabled. |
| observed | A `State` lifecycle helper moved into an extension and called protected `setState`, producing an analyzer warning. | Keep protected `State` calls in the `State` subclass; extracted parts may delegate back to an instance method. | Treat analyzer warnings as failures before commit. |
| observed | Drawer-only widget classes were split into separate libraries as public types, producing 22 documentation warnings and expanding the app API for implementation details. | Keep extracted implementation-only widget classes library-private through `part` files; make a type public only when another feature owns the contract. | Analyzer warnings fail the slice; review every new public Flutter type for a real cross-library consumer. |
| repeated | A repository-wide gate failed on known legacy files even though the changed slice was compliant. | Report baseline debt separately and prove every touched file passes the same limit. | CI should eventually compare new violations against an explicit baseline. |
| observed | A fixture sent multiple SQL statements through one Dust raw query, which rejects trailing statements. | Execute exactly one SQL statement per raw query call. | Fixture helpers should accept one statement and tests should fail on every returned database error. |
| observed | SQLx converter declarations lived in a Dart `part`; normal Dust generation lost their input types and emitted `read<Object?>`. | Keep SQLx converter declarations in the owning library until the generator resolves declarations across parts. | `dust check` and `dust check --db` must both inspect the generated read types. |
| observed | A diagnostic command followed a failed verifier in the same shell chain and its zero exit masked the failure. | Run the authoritative verifier as the terminal command or preserve and assert its exit code before diagnostics. | Verification scripts use strict mode and never append non-authoritative commands after the gate. |
| observed | A zsh QA script assigned to the read-only special parameter `status` and stopped before assertions. | Use task-scoped shell variable names that cannot collide with shell state. | Shellcheck plus a project prefix for temporary script variables. |
| observed | A live Admin fixture ignored a failed insert whose foreign-key prerequisite was absent, leaving the expected customer order missing. | Seed required parents and assert every fixture write before browser QA. | Shared seed helpers return failures; QA scripts stop on the first rejected write. |
| observed | The customer detail breakpoint was based on inner content width, while Medusa's `xl` decision is based on viewport width, so a 1280 viewport collapsed incorrectly. | Translate source breakpoints into the local shell's actual content threshold and verify both sides of the breakpoint. | Capture the same route at the target desktop viewport and one compact viewport before closing visual QA. |
| observed | A Git branch command was combined with Medusa source inspection and ran inside the pinned reference checkout. | Never combine repository mutation with cross-repository inspection in one shell invocation. | Give every Git mutation its own command with an explicit dust-commerce working directory and verify the branch immediately. |
| observed | A `FromRow`-only Dust type was declared with `with _$Type`, but that derive emits a row deserializer and query terminals, not a data-class mixin. | Infer generated API shape from the selected derives, not from another model using additional derives. | Inspect the generated file and compile a focused SQLx consumer after generation. |
| observed | A raw nullable SQL assertion called `readIndex<T?>`, but that API is strict and throws on SQL `NULL`. | Use `readIndexNullable<T>` for nullable raw-row assertions; generic nullability does not change strict reads. | Integration tests must exercise both null and present projections through the intended row API. |
| promoted | Visible Medusa copy or formatting was inferred from a component name or screenshot: the address form initially used “Add address”, and the customer-group table initially used “Created At” without the visible time. | Inspect the pinned component plus every locale and formatter it calls before implementing visible parity output; screenshots validate only the resulting render. | `CONTRIBUTING.md` requires source notes before pixel comparison; parity QA names the source paths and browser assertions. |
| observed | A two-column alignment spacer was emitted after switching the address grid to one column, leaving a full empty row on compact screens. | Keep source grid placeholders conditional on the breakpoint that needs them. | Exercise the same focus form at desktop and `390 x 844` before committing the UI slice. |
| observed | The package verifier passed a path deleted by the previous commit to `dart format`, producing a false missing-file warning after a rename. | Every Git-produced formatting list excludes deleted paths. | `scripts/verify_package.sh` applies `--diff-filter=ACMRT` to working-tree and committed-source scans; reproduce against rename commit `1676fd9`. |
| observed | Terminating a long-running Flutter or Dart wrapper left its spawned VM listening on the QA port, so the replacement processes failed to bind. | Before restarting local QA, resolve and stop the exact listener PID, then prove the port is free. | Check ports `3878`, `13001` and `13002` with `lsof` before launching replacement processes. |
| observed | Route-focus headers displayed an `esc` affordance, but pressing Escape left the form open. | Every visible keyboard affordance must invoke its advertised action and must respect the command's busy state. | Browser QA presses Escape on each new focus form and verifies dismissal or intentional blocking. |

## Entry template

Add a row only after a concrete correction:

```text
Status: observed | repeated | promoted
Source: user correction | self-correction
Symptom: what failed or created risk
Correction: what changed the decision
Candidate: the smallest durable rule
Enforcement: the cheapest reliable check
Evidence: affected slice plus branch, commit, test, or review reference
```
