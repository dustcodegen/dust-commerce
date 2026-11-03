import 'package:dust_dart/serde.dart';

import '../ordering/checkout_request.dart';

part 'cart_request.g.dart';

/// The body of `POST /carts`.
///
/// Request contracts live beside the response contracts, in the shared
/// package, for the same reason: the client encodes this class and the server
/// decodes it, so the shape is declared once and a change breaks both ends at
/// compile time.
///
/// Every field is optional: a storefront that has not asked the customer where
/// they are still needs a cart.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class CreateCartBody with _$CreateCartBody {
  /// Creates a [CreateCartBody].
  const CreateCartBody({this.regionId, this.email});

  /// Creates a [CreateCartBody] from JSON.
  factory CreateCartBody.fromJson(Map<String, Object?> json) =>
      _$CreateCartBodyFromJson(json);

  /// Where to reach a guest, when it is known this early.
  @Validate(email: true, message: 'Enter a valid email address')
  final String? email;

  /// The region to sell in, when the storefront has chosen one.
  final String? regionId;
}

/// The body of `PATCH /carts/{id}` when the selling region changes.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class UpdateCartRegionBody with _$UpdateCartRegionBody {
  /// Creates an explicit region replacement.
  const UpdateCartRegionBody({required this.regionId});

  /// Creates an [UpdateCartRegionBody] from JSON.
  factory UpdateCartRegionBody.fromJson(Map<String, Object?> json) =>
      _$UpdateCartRegionBodyFromJson(json);

  /// Region whose currency and selling rules should govern the cart.
  @Validate(length: Length(min: 1), message: 'region_id is required')
  final String regionId;
}

/// The atomic cart payload used by a checkout permalink.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class BuyCartBody with _$BuyCartBody {
  /// Creates a cart containing every requested line.
  const BuyCartBody({required this.items, this.regionId});

  /// Decodes a checkout-permalink request.
  factory BuyCartBody.fromJson(Map<String, Object?> json) =>
      _$BuyCartBodyFromJson(json);

  /// Every line is validated before the server writes the cart.
  @Validate(length: Length(min: 1), message: 'Add at least one item')
  final List<AddLineBody> items;

  /// Optional selling region selected by the storefront.
  final String? regionId;
}

/// The contact and destinations retained while checkout is in progress.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class UpdateCartAddressesBody with _$UpdateCartAddressesBody {
  /// Creates a complete replacement for the cart checkout addresses.
  const UpdateCartAddressesBody({
    required this.email,
    required this.shippingAddress,
    this.billingAddress,
  });

  /// Decodes the validated cart-address request.
  factory UpdateCartAddressesBody.fromJson(Map<String, Object?> json) =>
      _$UpdateCartAddressesBodyFromJson(_normalizedCartAddresses(json));

  /// Separate invoice destination, or absent when shipping is reused.
  @Validate(nested: true)
  final AddressInput? billingAddress;

  /// Receipt and delivery-contact email.
  @Validate(length: Length(min: 1), message: 'Enter an email address')
  @Validate(email: true, message: 'Enter a valid email address')
  final String email;

  /// Destination selected before delivery options are shown.
  @Validate(nested: true)
  final AddressInput shippingAddress;
}

Map<String, Object?> _normalizedCartAddresses(Map<String, Object?> json) => {
      ...json,
      if (json['email'] case final String value) 'email': value.trim(),
      if (json['shipping_address'] case final Map<Object?, Object?> address)
        'shipping_address': AddressInput.fromJson(address.cast()).toJson(),
      if (json['billing_address'] case final Map<Object?, Object?> address)
        'billing_address': AddressInput.fromJson(address.cast()).toJson(),
    };

/// The body of `POST /carts/{id}/line-items`.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class AddLineBody with _$AddLineBody {
  /// Creates an [AddLineBody].
  const AddLineBody({required this.variantId, this.quantity = 1});

  /// Creates an [AddLineBody] from JSON.
  factory AddLineBody.fromJson(Map<String, Object?> json) =>
      _$AddLineBodyFromJson(json);

  /// How many to add.
  ///
  /// Absent means one. The Dart default is not enough on its own: the
  /// generated deserialiser requires every non-nullable key unless a
  /// `defaultValue` says what a missing one means.
  @SerDe(defaultValue: 1)
  @Validate(range: Range(min: 1, max: 100), message: 'Order 1 to 100')
  final int quantity;

  /// The variant being added.
  @Validate(length: Length(min: 1), message: 'variant_id is required')
  final String variantId;
}

/// The body of `PATCH /carts/{id}/line-items/{lineId}`.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class UpdateLineBody with _$UpdateLineBody {
  /// Creates an [UpdateLineBody].
  const UpdateLineBody({required this.quantity});

  /// Creates an [UpdateLineBody] from JSON.
  factory UpdateLineBody.fromJson(Map<String, Object?> json) =>
      _$UpdateLineBodyFromJson(json);

  /// The complete replacement quantity, rather than an increment.
  @Validate(range: Range(min: 1), message: 'Order at least one')
  final int quantity;
}

/// The body of `POST /carts/{id}/shipping-method`.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class ChooseShippingBody with _$ChooseShippingBody {
  /// Creates a [ChooseShippingBody].
  const ChooseShippingBody({required this.optionId});

  /// Creates a [ChooseShippingBody] from JSON.
  factory ChooseShippingBody.fromJson(Map<String, Object?> json) =>
      _$ChooseShippingBodyFromJson(json);

  /// The option being chosen.
  @Validate(length: Length(min: 1), message: 'option_id is required')
  final String optionId;
}

/// The body of `POST /carts/{id}/payment-sessions`.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ChoosePaymentBody with _$ChoosePaymentBody {
  /// Creates an explicit payment-provider choice.
  const ChoosePaymentBody({required this.providerId});

  /// Creates a [ChoosePaymentBody] from JSON.
  factory ChoosePaymentBody.fromJson(Map<String, Object?> json) =>
      _$ChoosePaymentBodyFromJson(json);

  /// Public provider identifier offered by this checkout.
  @Validate(length: Length(min: 1), message: 'provider_id is required')
  final String providerId;
}

/// The body of `POST /carts/{id}/promotions`.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class ApplyPromotionBody with _$ApplyPromotionBody {
  /// Creates an [ApplyPromotionBody].
  const ApplyPromotionBody({required this.code});

  /// Creates an [ApplyPromotionBody] from JSON.
  factory ApplyPromotionBody.fromJson(Map<String, Object?> json) =>
      _$ApplyPromotionBodyFromJson(json);

  /// The code a customer typed.
  @Validate(length: Length(min: 1), message: 'code is required')
  final String code;
}
