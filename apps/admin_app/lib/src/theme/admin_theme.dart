import 'package:flutter/material.dart';

/// Owns the merchant's local light, dark, or system appearance choice.
final class AdminThemeController extends ValueNotifier<ThemeMode> {
  /// Starts with Medusa's documented light appearance.
  AdminThemeController() : super(ThemeMode.light);
}

/// Medusa Admin's restrained neutral palette and compact control geometry.
ThemeData adminTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final background = dark ? const Color(0xFF18181B) : const Color(0xFFF7F7F7);
  final surface = dark ? const Color(0xFF202023) : Colors.white;
  final field = dark ? const Color(0xFF303034) : const Color(0xFFF4F4F5);
  final foreground = dark ? const Color(0xFFFAFAFA) : const Color(0xFF18181B);
  final outline = dark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7);
  final scheme = ColorScheme.fromSeed(
    seedColor: foreground,
    brightness: brightness,
    surface: surface,
  ).copyWith(
    primary: foreground,
    onPrimary: background,
    outline: outline,
  );
  final base = ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    canvasColor: surface,
    dividerColor: outline,
    fontFamily: 'Inter',
    visualDensity: VisualDensity.compact,
    useMaterial3: true,
  );
  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: base.textTheme.bodyMedium?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w500,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(32, 32),
        maximumSize: const Size(32, 32),
        padding: EdgeInsets.zero,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: field,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: outline),
      ),
    ),
    textTheme: base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 13),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: outline),
      ),
    ),
  );
}
