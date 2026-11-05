import 'dart:convert';

import 'package:commerce_shared/commerce_shared.dart';

/// Builds the home-route JSON-LD projection used by the Medusa storefront.
String buildStoreHomeStructuredData({
  required Uri currentUri,
  required List<Region> regions,
}) {
  final homeUrl = _canonicalUrl(currentUri);
  final origin = _origin(currentUri);
  final returnPolicies = [
    for (final region in regions)
      if (region.policy case final policy?)
        for (final country in region.countries)
          {
            '@type': 'MerchantReturnPolicy',
            'applicableCountry': country.toUpperCase(),
            'returnPolicyCategory':
                'https://schema.org/MerchantReturnFiniteReturnWindow',
            'merchantReturnDays': policy.returnWindowDays,
            'returnMethod': 'https://schema.org/ReturnByMail',
            'returnFees': policy.freeReturns
                ? 'https://schema.org/FreeReturn'
                : 'https://schema.org/ReturnFeesCustomerResponsibility',
          },
  ];
  final searchUrl = '${homeUrl.replaceFirst(RegExp(r'/+$'), '')}/search';
  final data = [
    {
      '@context': 'https://schema.org',
      '@type': 'Organization',
      'name': 'Morrow',
      'url': origin,
      if (returnPolicies.isNotEmpty) 'hasMerchantReturnPolicy': returnPolicies,
    },
    {
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      'name': 'Morrow',
      'url': homeUrl,
      'potentialAction': {
        '@type': 'SearchAction',
        'target': {
          '@type': 'EntryPoint',
          'urlTemplate': '$searchUrl?q={search_term_string}',
        },
        'query-input': 'required name=search_term_string',
      },
    },
  ];
  return jsonEncode(data).replaceAll('<', r'\u003c');
}

String _canonicalUrl(Uri currentUri) {
  final value = currentUri.toString();
  final queryStart = value.indexOf('?');
  final fragmentStart = value.indexOf('#');
  var end = value.length;
  if (queryStart >= 0 && queryStart < end) end = queryStart;
  if (fragmentStart >= 0 && fragmentStart < end) end = fragmentStart;
  return value.substring(0, end);
}

String _origin(Uri uri) {
  if (uri.scheme.isEmpty || uri.host.isEmpty) return '';
  final port = uri.hasPort ? ':${uri.port}' : '';
  return '${uri.scheme}://${uri.host}$port';
}
