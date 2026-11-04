# Contributing

## Rules that are not negotiable

1. **Tests first.** Write the failing test, watch it fail for the right reason,
   then write the code. A test written after the code proves the code runs, not
   that it is correct.
2. **180 lines of code per file.** Generated `.g.dart` files are exempt; they
   are output, not source. When a file crosses the limit, split by
   responsibility, never by line count.
3. **A folder is not scaffolded before an issue needs code in it.** An empty
   directory implying a route we do not serve is worse than no directory.
4. **Backend operations are named `create`, `read`, `update`, `delete`,
   `list`.** Nothing else, in `handler/`, `service/` or `repository/`. One that
   outgrows the budget becomes a folder of the same name. See
   [the backend structure](docs/architecture/backend-structure.md).
5. **Generated output is ignored.** Run `./scripts/generate.sh` before local
   analysis or tests. CI starts without `.g.dart`, regenerates every Dust root,
   then runs `dust check` and `dust check --db` before compiling consumers.
6. **One `Result` per boundary.** Never return `Result<Result<T, DomainError>,
   DatabaseError>`. Define one feature failure type, include an internal/database
   variant, and flatten infrastructure errors before returning from the service.
7. **Widget subtrees are widget classes.** Do not hide UI composition in a
   private function or method returning `Widget`. Give the subtree a focused
   `StatelessWidget` or `StatefulWidget` so ownership, lifecycle and rebuild
   boundaries stay visible.
8. **Package verification starts at the repository root.** Run
   `./scripts/verify_package.sh <package>` so source paths, Dust roots, working
   directories and the Dart/Flutter test runner come from one checked contract.
9. **Source parity comes before pixel comparison.** Pin the reference commit,
   inspect the component plus every locale and formatter it calls, and record
   the exact visible output before implementing Flutter. Browser screenshots
   verify the finished render; they do not replace source truth.

## Splitting

A file that crosses 180 lines becomes a folder of the same name, with a barrel
file exporting the parts:

```text
repository/
├── repository.dart   # exports
├── create/
│   ├── create.dart   # exports
│   ├── insert.dart
│   └── validate.dart
└── get.dart
```

A split that leaves one file holding everything and another holding a helper has
not divided a responsibility; it has moved a line count.

## Ordering

- Sort files and folders A–Z where practical.
- Group a file by section, sort members A–Z within a section.
- Public items above private helpers, so a reader meets the contract before the
  mechanics.

## Commits

Conventional commits. The body says why, not what — the diff already says what.

Repeated user and self-corrections are collected in the
[correction pattern ledger](docs/correction-patterns.md). Its candidates become
rules here only after recurrence and an enforcement path are clear.

## Verifying

```bash
./scripts/verify_package.sh packages/commerce_admin_shared
./scripts/verify_package.sh packages/commerce_server
./scripts/verify_package.sh apps/admin_app
```

```bash
./scripts/format.sh && ./scripts/check_file_size.sh && ./scripts/check_structure.sh
```

Never run `dart format` across a package. It rewrites generated files into
something the generator would not emit, and `dust check` then reports all of
them stale. `scripts/format.sh` formats handwritten Dart and skips the rest.
