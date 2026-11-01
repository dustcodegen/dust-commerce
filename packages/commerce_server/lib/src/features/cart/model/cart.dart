import 'dart:convert';

import 'package:commerce_server/src/features/cart/model/line_item.dart';
import 'package:commerce_server/src/features/cart/model/promotion.dart';
import 'package:commerce_server/src/features/cart/model/region.dart';
import 'package:commerce_server/src/features/cart/model/shipping.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'cart.g.dart';
part 'cart_totals.dart';

/// Explicit cart response populated directly from the cart-and-region query.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CartResponse with _$CartResponse {
  /// Creates an allowlisted cart response.
  const CartResponse({
    required this.id,
    required this.region,
    required this.items,
    required this.promotions,
    this.customerId,
    this.email,
    this.shippingAddress,
    this.billingAddress,
    this.shippingMethod,
    this.paymentSession,
  });

  /// Separate invoice destination, absent when shipping is reused.
  @Sqlx(rename: 'billing_address', tryFrom: OptionalAddressFromJson())
  final Address? billingAddress;

  /// Customer owner once this guest cart is claimed.
  @Sqlx(rename: 'customer_id')
  final String? customerId;

  /// Guest or customer contact email stored on the cart.
  final String? email;

  /// Stable cart identifier.
  final String id;

  /// Explicit line-item responses.
  @Sqlx(tryFrom: LineItemsFromJson())
  final List<LineItemResponse> items;

  /// Explicit customer-facing promotion snapshots.
  @Sqlx(tryFrom: CartPromotionsSqlxJson())
  final List<AppliedPromotionResponse> promotions;

  /// Explicit public payment choice retained during checkout.
  @Sqlx(
    rename: 'payment_session',
    tryFrom: OptionalPaymentSessionFromJson(),
  )
  final CartPaymentSession? paymentSession;

  /// Explicit selling-region response.
  @Sqlx(tryFrom: RegionResponseFromJson())
  final RegionResponse region;

  /// Delivery destination retained during checkout.
  @Sqlx(rename: 'shipping_address', tryFrom: OptionalAddressFromJson())
  final Address? shippingAddress;

  /// Explicit selected delivery response.
  @Sqlx(
    rename: 'shipping_method',
    tryFrom: OptionalShippingMethodFromJson(),
  )
  final ShippingMethodResponse? shippingMethod;
}

/// Decodes an optional allowlisted cart payment-session response.
final class OptionalPaymentSessionFromJson
    implements SqlxTryFrom<CartPaymentSession?, String> {
  /// Creates the stateless converter.
  const OptionalPaymentSessionFromJson();

  @override
  CartPaymentSession? decode(String value) =>
      value == 'null' ? null : CartPaymentSession.fromJson(_object(value));
}

/// Keeps PostgreSQL JSON transport explicit to the local FromRow resolver.
final class CartPromotionsSqlxJson
    implements SqlxTryFrom<List<AppliedPromotionResponse>, String> {
  /// Creates the stateless adapter.
  const CartPromotionsSqlxJson();

  @override
  List<AppliedPromotionResponse> decode(String value) =>
      const AppliedPromotionsFromJson().decode(value);
}

/// Builds explicit line responses from a SQLite JSON aggregate.
final class LineItemsFromJson
    implements SqlxTryFrom<List<LineItemResponse>, String> {
  /// Creates the stateless converter.
  const LineItemsFromJson();

  @override
  List<LineItemResponse> decode(String value) => [
        for (final item in jsonDecode(value) as List<Object?>)
          decodeItem(item! as Map<String, Object?>),
      ];

  /// Decodes one line object reused by immutable order snapshots.
  static LineItemResponse decodeItem(Map<String, Object?> item) =>
      LineItemResponse(
        id: item['id']! as String,
        variantId: item['variant_id']! as String,
        productId: item['product_id']! as String,
        productHandle: item['product_handle']! as String,
        title: item['title']! as String,
        variantTitle: item['variant_title'] as String?,
        thumbnail: item['thumbnail'] as String?,
        unitPrice: Money.fromJson(
          item['unit_price']! as Map<String, Object?>,
        ),
        quantity: item['quantity']! as int,
      );
}

/// Decodes an optional explicit shipping-method response.
final class OptionalShippingMethodFromJson
    implements SqlxTryFrom<ShippingMethodResponse?, String> {
  /// Creates the stateless converter.
  const OptionalShippingMethodFromJson();

  @override
  ShippingMethodResponse? decode(String value) {
    if (value == 'null') return null;
    final json = _object(value);
    return ShippingMethodResponse(
      optionId: json['option_id']! as String,
      name: json['name']! as String,
      amount: Money.fromJson(json['amount']! as Map<String, Object?>),
    );
  }
}

/// Decodes one optional checkout address selected as JSON.
final class OptionalAddressFromJson implements SqlxTryFrom<Address?, String> {
  /// Creates the stateless converter.
  const OptionalAddressFromJson();

  @override
  Address? decode(String value) =>
      value == 'null' ? null : Address.fromJson(_object(value));
}

/// Builds an explicit region response from a JSON object selected by SQLite.
final class RegionResponseFromJson
    implements SqlxTryFrom<RegionResponse, String> {
  /// Creates the stateless converter.
  const RegionResponseFromJson();

  @override
  RegionResponse decode(String value) {
    final json = _object(value);
    return RegionResponse(
      id: json['id']! as String,
      name: json['name']! as String,
      currencyCode: json['currency_code']! as String,
      taxRate: json['tax_rate']! as int,
      countries: (json['countries']! as String)
          .split(',')
          .where((country) => country.isNotEmpty)
          .toList(growable: false),
      taxInclusive: json['tax_inclusive']! as int != 0,
    );
  }
}

Map<String, Object?> _object(String value) =>
    jsonDecode(value) as Map<String, Object?>;
