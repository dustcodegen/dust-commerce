import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/i18n/app_i18n.g.dart';
import 'package:commerce_app/src/app/commerce_app.dart';
import 'package:dust_dart/http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

/// Runs the storefront.
///
/// The API base URL is compile-time configurable so the same build can point
/// at a local server or a deployed one without a code change:
/// `flutter run --dart-define=API_BASE_URL=https://…`.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3878',
  );

  final sessions = SecureAuthSessionStore();
  final dio = Dio()
    ..interceptors.add(AuthorizationInterceptor(sessions: sessions));

  runApp(
    AppI18n(
      child: CommerceApp(
        api: CommerceApi(dio, baseUrl: baseUrl),
        returnHistoryApi: OrderReturnHistoryApi(dio, baseUrl: baseUrl),
        sessions: sessions,
        countries: SecureCountryPreferenceStore(),
        locales: SecureLocalePreferenceStore(),
        initialLocation: kIsWeb
            ? Uri.base
            : Uri.parse(
                WidgetsBinding.instance.platformDispatcher.defaultRouteName,
              ),
      ),
    ),
  );
}
