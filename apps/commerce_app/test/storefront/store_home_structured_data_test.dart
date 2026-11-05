import 'dart:convert';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home JSON-LD publishes source-shaped organization and search data', () {
    final policy = const StoreRegionPolicy(
      freeReturns: true,
      handlingDaysMax: 2,
      handlingDaysMin: 1,
      returnWindowDays: 30,
      shippingRate: '10',
      transitDaysMax: 3,
      transitDaysMin: 2,
    );
    final regions = [
      Region.of(
        id: 'reg_eur',
        name: 'Europe',
        currencyCode: 'eur',
        taxRate: 2000,
        countries: const ['dk', 'de'],
        policy: policy,
      ),
      Region.of(
        id: 'reg_us',
        name: 'United States',
        currencyCode: 'usd',
        taxRate: 0,
        countries: const ['us'],
      ),
    ];

    final data = jsonDecode(
      buildStoreHomeStructuredData(
        currentUri: Uri.parse('https://shop.test/dk?ref=home#top'),
        regions: regions,
      ),
    ) as List<Object?>;
    final organization = data[0] as Map<String, Object?>;
    final website = data[1] as Map<String, Object?>;

    expect(organization['@type'], 'Organization');
    expect(organization['url'], 'https://shop.test');
    final policies = organization['hasMerchantReturnPolicy']! as List<Object?>;
    expect(policies, hasLength(2));
    expect(
      (policies.first! as Map<String, Object?>)['applicableCountry'],
      'DK',
    );

    expect(website['@type'], 'WebSite');
    expect(website['url'], 'https://shop.test/dk');
    final action = website['potentialAction'] as Map<String, Object?>;
    final target = action['target'] as Map<String, Object?>;
    expect(target['urlTemplate'], contains('/search?q={search_term_string}'));
    expect(action['query-input'], 'required name=search_term_string');
  });

  test('home JSON-LD omits policies when no region policy is published', () {
    final data = jsonDecode(
      buildStoreHomeStructuredData(
        currentUri: Uri.parse('https://shop.test/'),
        regions: [
          Region.of(
            id: 'reg_us',
            name: 'United States',
            currencyCode: 'usd',
            taxRate: 0,
            countries: const ['us'],
          ),
        ],
      ),
    ) as List<Object?>;

    expect(
      (data.first! as Map<String, Object?>).containsKey(
        'hasMerchantReturnPolicy',
      ),
      isFalse,
    );
  });
}
