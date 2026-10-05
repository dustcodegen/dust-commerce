import 'package:flutter/material.dart';

/// Medusa UI light tokens used by the source storefront.
abstract final class StoreColors {
  /// Main page and component background.
  static const base = Color(0xffffffff);

  /// Quiet surfaces such as product images and option controls.
  static const subtle = Color(0xfffafafa);

  /// Tailwind gray-50 used by the pinned account order-summary cards.
  static const neutral50 = Color(0xfff9fafb);

  /// Hover state for quiet surfaces.
  static const subtleHover = Color(0xfff4f4f5);

  /// Default divider and control border.
  static const border = Color(0xffe4e4e7);

  /// Stronger neutral border.
  static const borderStrong = Color(0xffd4d4d8);

  /// Selected-control border and focus color.
  static const interactive = Color(0xff3b82f6);

  /// Successful transfer feedback from the source emerald token.
  static const success = Color(0xff10b981);

  /// Failed transfer feedback from the source red token.
  static const danger = Color(0xffef4444);

  /// Transfer-request feedback from the source rose token.
  static const rose = Color(0xfff43f5e);

  /// Primary action surface used by the DTC storefront button component.
  static const buttonPrimary = Color(0xff000000);

  /// Tailwind gray-800 hover used by the DTC primary button component.
  static const buttonPrimaryHover = Color(0xff1f2937);

  /// Primary foreground.
  static const foreground = Color(0xff18181b);

  /// Secondary foreground.
  static const foregroundSubtle = Color(0xff52525b);

  /// Tertiary foreground.
  static const foregroundMuted = Color(0xff71717a);

  /// Disabled foreground.
  static const foregroundDisabled = Color(0xffa1a1aa);

  /// Inverted button and menu surface.
  static const inverted = Color(0xff27272a);
}

/// Builds the storefront theme from the same semantic tokens as Medusa UI.
abstract final class StoreTheme {
  /// Production light theme for the customer storefront.
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: StoreColors.interactive,
      onPrimary: StoreColors.base,
      surface: StoreColors.base,
      onSurface: StoreColors.foreground,
      outline: StoreColors.border,
      outlineVariant: StoreColors.borderStrong,
    );
    const textTheme = TextTheme(
      headlineMedium: TextStyle(
        fontSize: 30,
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, height: 24 / 14),
      bodySmall: TextStyle(fontSize: 12, height: 20 / 12),
      labelLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      // The storefront targets web controls at their authored CSS sizes.
      // Flutter otherwise compacts button geometry on desktop platforms.
      visualDensity: VisualDensity.standard,
      colorScheme: scheme,
      scaffoldBackgroundColor: StoreColors.base,
      fontFamily: 'Inter',
      fontFamilyFallback: const [
        '.AppleSystemUIFont',
        'Segoe UI',
        'Roboto',
        'Helvetica Neue',
        'Arial',
      ],
      textTheme: textTheme.apply(
        bodyColor: StoreColors.foreground,
        displayColor: StoreColors.foreground,
      ),
      dividerTheme: const DividerThemeData(
        color: StoreColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: StoreColors.base,
        foregroundColor: StoreColors.foregroundSubtle,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: StoreColors.border)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: StoreColors.foregroundSubtle,
          textStyle: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: StoreColors.buttonPrimary,
          foregroundColor: StoreColors.base,
          disabledBackgroundColor: const Color(0xff808080),
          disabledForegroundColor: StoreColors.base,
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: StoreColors.foreground,
          backgroundColor: StoreColors.base,
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: const BorderSide(color: StoreColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: StoreColors.interactive,
      ),
    );
  }
}
