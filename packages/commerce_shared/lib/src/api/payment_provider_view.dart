import 'package:dust_dart/serde.dart';

part 'payment_provider_view.g.dart';

/// One public payment provider available to a selling region.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class PaymentProviderView with _$PaymentProviderView {
  /// Creates a public provider reference.
  const PaymentProviderView({required this.id});

  /// Decodes a provider returned by the store API.
  factory PaymentProviderView.fromJson(Map<String, Object?> json) =>
      _$PaymentProviderViewFromJson(json);

  /// Stable identifier submitted when a payment session is selected.
  final String id;
}

/// Public list returned by Medusa's payment-provider route.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class PaymentProviderListView with _$PaymentProviderListView {
  /// Creates a complete regional provider listing.
  const PaymentProviderListView({required this.paymentProviders});

  /// Decodes the provider list returned by the store API.
  factory PaymentProviderListView.fromJson(Map<String, Object?> json) =>
      _$PaymentProviderListViewFromJson(json);

  /// Enabled providers in stable identifier order.
  final List<PaymentProviderView> paymentProviders;
}
