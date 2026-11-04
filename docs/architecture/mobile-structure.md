# Mobile Module Structure

Feature-first MVVM. A feature owns its screens, its view models, and the
widgets only it uses. Shared code earns its place by being used twice.

Do not scaffold a folder before an issue needs code in it.

## Top-level tree

```text
apps/commerce_app/
├── lib/
│   ├── main.dart
│   ├── route.dart      # the one routing entrypoint Dust requires
│   └── src/
│       ├── core/       # cross-feature primitives
│       ├── features/   # product behaviour
│       └── shared/     # widgets used by more than one feature
└── test/
```

## Ownership

### `core/`

The API client, formatting, theming, and error presentation. Things every
feature depends on and none of them owns.

### `shared/`

Widgets used by more than one feature. A widget used once lives in the feature
that uses it. Moving it here is a decision made on the second use, not the
first.

## Feature tree

```text
features/<feature>/
├── <feature>.dart        # feature exports
├── model/                # view-facing types, when the shared model is wrong
├── view/                 # screens, one file per route
│   ├── view.dart
│   └── <screen>_page.dart
├── view_model/           # one per screen
│   ├── view_model.dart
│   └── <screen>_view_model.dart
└── widget/               # widgets only this feature uses
```

The dependency direction is `view → view_model → core/api`. A view never calls
the API, and a view model never imports Flutter widgets.

Widget composition is structural code. A private function or method returning
`Widget` hides that structure from Flutter's element model and from reviewers.
Extract a focused `StatelessWidget` or `StatefulWidget`; keep ordinary callbacks
as methods. Existing violations are frozen by `scripts/check_structure.sh` and
must only decrease.

## MVVM contract

- A view model is annotated `@ViewModel` and extends its generated base.
- Everything the UI renders lives in the view model's state. A widget holding
  state that outlives a frame is a bug.
- `watchXViewModel().value` in `build` only.
- `readXViewModel()` in callbacks, lifecycle, and dependency factories.

Reading `watch` outside `build` rebuilds nothing and silently desynchronises the
UI, which is why the two are separate calls rather than one.

## Routes

One `lib/route.dart` entrypoint, extending the generated `$RootRouter`. Screens
carry `@AppRoute`. Route names are the feature's, not the widget's.

## Tests

```text
test/
└── <feature>/
    ├── <screen>_view_model_test.dart   # state transitions, no widgets
    └── <screen>_page_test.dart         # widget tests
```

View model tests come first and outnumber widget tests. A view model is pure
Dart and a widget test is not; the logic worth testing lives in the former.
