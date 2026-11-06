import 'package:commerce_server/src/features/catalog/model.dart';
import 'package:commerce_server/src/features/catalog/repository/repository.dart';
import 'package:commerce_server/src/features/catalog/variant_response.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// One complete published product, or [None] when nothing matches [handle].
Future<Result<Option<ProductResponse>, SqlxError>> findProduct(
  CatalogReadRepository reads, {
  required String handle,
  required String currencyCode,
}) async {
  final found = await reads.findByHandle(handle, currencyCode);
  return switch (found) {
    Ok(:final value) => Ok(optionOf<ProductResponse>(value)),
    Err(:final error) => Err(error),
  };
}

/// Renders the source's machine-readable product representation.
String renderProductMarkdown(
  ProductResponse product, {
  required String origin,
  required String countryCode,
  required String currencyCode,
  StoreRegionPolicy? policy,
}) {
  final base = '$origin/$countryCode';
  final optionTitles = <String, String>{
    for (final option in product.options) option.id: option.title,
  };
  final variants = product.variants.map((variant) {
    final options = variant.optionValues.entries
        .map(
          (entry) => '${optionTitles[entry.key] ?? 'Option'}: ${entry.value}',
        )
        .join(', ');
    final price = variant.prices.firstOrNull;
    final renderedPrice = price == null ? '' : _formatMoney(price);
    final availability = _isInStock(variant) ? 'In stock' : 'Out of stock';
    return '| ${options.isEmpty ? variant.title : options} | '
        '${variant.sku ?? ''} | $renderedPrice | $availability | '
        '`${variant.id}` |';
  }).join('\n');
  final shipping = policy == null
      ? null
      : policy.shippingRate == '0'
          ? 'free'
          : '${policy.shippingRate} ${currencyCode.toUpperCase()}';
  final policyLines = policy == null
      ? ''
      : '\n- Shipping: $shipping, '
          'ships in ${_dayRange(policy.handlingDaysMin, policy.handlingDaysMax)} '
          'business days, delivery '
          '${_dayRange(policy.transitDaysMin, policy.transitDaysMax)} '
          'business days\n- Returns: within ${policy.returnWindowDays} '
          'days of delivery, '
          '${policy.freeReturns ? 'free return shipping' : 'return shipping paid by the customer'}';

  return '''
# ${product.title}

${product.description ?? ''}

- URL: $base/products/${product.handle}
- Availability: ${product.variants.any(_isInStock) ? 'In stock' : 'Out of stock'}$policyLines

## Variants

| Options | SKU | Price | Availability | Variant ID |
| --- | --- | --- | --- | --- |
$variants

## Buy

- Add to cart: POST `variant_id={variant_id}&quantity={n}` (form-encoded) to $origin/store/cart/add
- Checkout link: $origin/buy/{variant_id}:{quantity}?context/address_country=${countryCode.toUpperCase()}

## Policies

- [Shipping information]($base/shipping)
- [Return policy]($base/returns)
- [Terms of service]($base/terms)
- [Privacy policy]($base/privacy)
- [Contact]($base/contact)
''';
}

bool _isInStock(ProductVariantResponse variant) =>
    !variant.manageInventory ||
    variant.allowBackorder ||
    variant.inventoryQuantity > 0;

String _formatMoney(Money money) {
  final absolute = money.amount.abs();
  final major = absolute ~/ 100;
  final minor = (absolute % 100).toString().padLeft(2, '0');
  final sign = money.amount.isNegative ? '-' : '';
  return '$sign${money.currencyCode.toUpperCase()} $major.$minor';
}

String _dayRange(int minimum, int maximum) =>
    minimum == maximum ? '$minimum' : '$minimum-$maximum';
