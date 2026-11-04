# Morrow admin

Dedicated Flutter web client for the merchant-only dust-commerce admin API.
It uses port `13002` locally and never shares a customer storefront session.

Bootstrap an admin with the repository root instructions, then run:

```bash
cd apps/admin_app
flutter run -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port 13002 \
  --dart-define=API_BASE_URL=http://127.0.0.1:3878
```
