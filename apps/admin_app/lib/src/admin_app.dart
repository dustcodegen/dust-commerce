import 'package:admin_app/src/session/admin_gate.dart';
import 'package:admin_app/src/theme/admin_theme.dart';
import 'package:flutter/material.dart';

/// Dedicated merchant application; no storefront routes are mounted here.
class MorrowAdminApp extends StatelessWidget {
  /// Creates the admin application.
  const MorrowAdminApp({required this.themes, super.key});

  /// Local merchant appearance preference.
  final AdminThemeController themes;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: themes,
        builder: (context, mode, child) => MaterialApp(
          title: 'Morrow Admin',
          debugShowCheckedModeBanner: false,
          theme: adminTheme(Brightness.light),
          darkTheme: adminTheme(Brightness.dark),
          themeMode: mode,
          home: AdminGate(themes: themes),
        ),
      );
}
