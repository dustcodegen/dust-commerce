import 'package:admin_app/src/admin_app.dart';
import 'package:admin_app/src/bootstrap/admin_dependencies.dart';
import 'package:admin_app/src/bootstrap/admin_view_model_scope.dart';
import 'package:admin_app/src/theme/admin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

/// Starts merchant admin on its isolated API and session boundary.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3878',
  );
  runApp(AdminViewModelScope(
    dependencies: AdminDependencies(baseUrl),
    child: MorrowAdminApp(themes: AdminThemeController()),
  ));
}
