import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/i18n/app_i18n.g.dart';
import 'package:country_flags/country_flags.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source-shaped language control shown above the country selector.
final class StoreLanguageSelect extends StatelessWidget {
  /// Creates the shared storefront-language selector.
  const StoreLanguageSelect({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watchStoreShellViewModel().value;
    if (shell.supportedLocales.isEmpty) return const SizedBox.shrink();
    final selected = shell.selectedLocaleCode.match(
      some: (locale) => locale,
      none: () => '',
    );
    final options = ['', ...shell.supportedLocales];

    return PopupMenuButton<String>(
      color: Colors.white,
      onSelected: (locale) => unawaited(_change(context, locale)),
      itemBuilder: (context) => [
        for (final locale in options)
          PopupMenuItem(
            value: locale,
            child: Row(
              children: [
                _StoreLocaleFlag(locale: locale),
                const SizedBox(width: 8),
                Text(_label(context, locale)),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              context.tr('shop_language_label', defaultText: 'Language:'),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 8),
            _StoreLocaleFlag(locale: selected),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _label(context, selected),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _change(BuildContext context, String locale) async {
    final preference = locale.isEmpty ? const None<String>() : Some(locale);
    final changed = await context.readStoreShellViewModel().selectLocale(
          preference,
        );
    if (!changed || !context.mounted) return;
    I18nScope.of(context).setLocale(
      locale.isEmpty ? appI18nFallbackLocale : locale,
    );
    Navigator.of(context).pop();
  }

  String _label(BuildContext context, String locale) => switch (locale) {
        'en' => context.tr('shop_language_english', defaultText: 'English'),
        'my' => context.tr('shop_language_burmese', defaultText: 'Burmese'),
        _ => context.tr('shop_language_default', defaultText: 'Default'),
      };
}

final class _StoreLocaleFlag extends StatelessWidget {
  const _StoreLocaleFlag({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) => switch (locale) {
        'en' => CountryFlag.fromCountryCode(
            'us',
            theme: const ImageTheme(width: 16, height: 16),
          ),
        'my' => CountryFlag.fromCountryCode(
            'mm',
            theme: const ImageTheme(width: 16, height: 16),
          ),
        _ => const SizedBox(width: 16, height: 16),
      };
}
