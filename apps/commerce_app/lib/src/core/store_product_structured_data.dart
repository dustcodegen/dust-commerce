import 'dart:convert';

import 'package:commerce_shared/commerce_shared.dart';

/// Builds the source-shaped JSON-LD projection for a public product page.
///
/// The wire document contains only customer-visible product, pricing and
/// availability fields. It never serializes the full Dart model, so internal
/// inventory or merchandising fields cannot leak into the document head.
String buildStoreProductStructuredData({
  required Product product,
  required String currencyCode,
  required String productUrl,
  String countryCode = '',
  StoreRegionPolicy? policy,
}) {
  final currency = currencyCode.toUpperCase();
  final images = <String>[
    for (final image in product.images)
      if (image.url.isNotEmpty) image.url,
  ];
  if (images.isEmpty) {
    final thumbnail = product.thumbnail;
    if (thumbnail != null && thumbnail.isNotEmpty) images.add(thumbnail);
  }

  final optionTitles = <String, String>{
    for (final option in product.options) option.id: option.title,
  };
  final variants = [
    for (final variant in product.variants)
      if (variant.priceIn(currencyCode) case final price?)
        (variant: variant, price: price),
  ];

  Map<String, Object?> buildOffer(
    ProductVariant variant,
    Money price,
    String url,
  ) {
    final offer = <String, Object?>{
      '@type': 'Offer',
      'url': url,
      if (variant.sku case final sku?) 'sku': sku,
      'price': (price.amount / 100).toStringAsFixed(2),
      'priceCurrency': currency,
      'availability': variant.isInStock
          ? 'https://schema.org/InStock'
          : 'https://schema.org/OutOfStock',
      'itemCondition': 'https://schema.org/NewCondition',
    };
    if (policy != null && countryCode.isNotEmpty) {
      offer.addAll({
        'shippingDetails': {
          '@type': 'OfferShippingDetails',
          'shippingRate': {
            '@type': 'MonetaryAmount',
            'value': num.parse(policy.shippingRate),
            'currency': currency,
          },
          'shippingDestination': {
            '@type': 'DefinedRegion',
            'addressCountry': countryCode.toUpperCase(),
          },
          'deliveryTime': {
            '@type': 'ShippingDeliveryTime',
            'handlingTime': _businessDays(
              policy.handlingDaysMin,
              policy.handlingDaysMax,
            ),
            'transitTime': _businessDays(
              policy.transitDaysMin,
              policy.transitDaysMax,
            ),
          },
        },
        'hasMerchantReturnPolicy': {
          '@type': 'MerchantReturnPolicy',
          'applicableCountry': countryCode.toUpperCase(),
          'returnPolicyCategory':
              'https://schema.org/MerchantReturnFiniteReturnWindow',
          'merchantReturnDays': policy.returnWindowDays,
          'returnMethod': 'https://schema.org/ReturnByMail',
          'returnFees': policy.freeReturns
              ? 'https://schema.org/FreeReturn'
              : 'https://schema.org/ReturnFeesCustomerResponsibility',
        },
      });
    }
    return offer;
  }

  final data = <String, Object?>{
    '@context': 'https://schema.org',
    '@type': variants.length <= 1 ? 'Product' : 'ProductGroup',
    'name': product.title,
    'description': product.description?.trim().isNotEmpty == true
        ? product.description!.trim()
        : product.title,
    if (images.isNotEmpty) 'image': images,
    'brand': const {'@type': 'Brand', 'name': 'Morrow'},
    'url': productUrl,
  };

  if (variants.length <= 1) {
    final only = variants.firstOrNull;
    data.addAll({
      if (only?.variant.sku case final sku?) 'sku': sku,
      if (only != null)
        'offers': buildOffer(only.variant, only.price, productUrl),
    });
  } else {
    data.addAll({
      'productGroupID': product.id,
      'variesBy': [for (final option in product.options) option.title],
      'hasVariant': [
        for (final entry in variants)
          {
            '@type': 'Product',
            'name': '${product.title} - ${entry.variant.title}',
            if (entry.variant.sku case final sku?) 'sku': sku,
            if (entry.variant.images.firstOrNull?.url case final image?)
              'image': image
            else if (images.isNotEmpty)
              'image': images.first,
            if (entry.variant.optionValues.isNotEmpty)
              'additionalProperty': [
                for (final choice in entry.variant.optionValues.entries)
                  {
                    '@type': 'PropertyValue',
                    'name': optionTitles[choice.key] ?? 'Option',
                    'value': choice.value,
                  },
              ],
            'offers': buildOffer(
              entry.variant,
              entry.price,
              '$productUrl?v_id=${Uri.encodeQueryComponent(entry.variant.id)}',
            ),
          },
      ],
    });
  }

  // Keep a JSON-LD script safe even when merchant-controlled text contains a
  // closing-script sequence.
  return jsonEncode(data).replaceAll('<', r'\u003c');
}

Map<String, Object?> _businessDays(int minimum, int maximum) => {
      '@type': 'QuantitativeValue',
      'minValue': minimum,
      'maxValue': maximum,
      'unitCode': 'DAY',
    };
