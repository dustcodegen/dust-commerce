import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Localized display name for one ISO 3166-1 alpha-2 country code.
String countryName(BuildContext context, String code) => switch (code) {
      'de' => context.tr('shop_country_germany', defaultText: 'Germany'),
      'dk' => context.tr('shop_country_denmark', defaultText: 'Denmark'),
      'es' => context.tr('shop_country_spain', defaultText: 'Spain'),
      'fr' => context.tr('shop_country_france', defaultText: 'France'),
      'gb' => context.tr(
          'shop_country_united_kingdom',
          defaultText: 'United Kingdom',
        ),
      'it' => context.tr('shop_country_italy', defaultText: 'Italy'),
      'se' => context.tr('shop_country_sweden', defaultText: 'Sweden'),
      'us' => context.tr(
          'shop_country_united_states',
          defaultText: 'United States',
        ),
      _ => code.toUpperCase(),
    };
