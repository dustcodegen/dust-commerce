import 'package:dust_dart/serde.dart';

part 'cart_payment_session.g.dart';

/// The allowlisted payment choice retained on a cart during checkout.
///
/// Provider credentials and internal adapter state never cross this contract.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CartPaymentSession with _$CartPaymentSession {
  /// Creates a public cart payment-session view.
  const CartPaymentSession({required this.providerId});

  /// Decodes the server-owned payment choice.
  factory CartPaymentSession.fromJson(Map<String, Object?> json) =>
      _$CartPaymentSessionFromJson(json);

  /// Stable provider identifier understood by checkout.
  final String providerId;
}
