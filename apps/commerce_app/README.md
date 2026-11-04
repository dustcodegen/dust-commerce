# Commerce app

Flutter storefront translated from the pinned Medusa DTC Starter source into
Dust routes, state, HTTP clients, and shared Dart models.

Run the seeded API from the repository root, then start the web storefront:

```bash
cd apps/commerce_app
flutter run -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port 13001 \
  --dart-define=API_BASE_URL=http://127.0.0.1:3878
```

`13001` is the storefront's repository-owned development port.

The UI is a source-guided reimplementation. It does not bundle the Medusa
React application or depend on the Medusa runtime.

Production hosting must serve `index.html` for unknown application paths so
cold links such as `/products/t-shirt` reach the Dust route parser.
