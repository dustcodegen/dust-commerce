import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

/// Explicit public payment receipt; provider metadata never crosses the API.
final class OrderPaymentResponse implements Serializable {
  /// Creates a safe payment receipt from persisted provider facts.
  const OrderPaymentResponse({
    required this.providerId,
    required this.amount,
    required this.createdAt,
  });

  /// Amount authorised against the frozen order total.
  final Money amount;

  /// When this provider payment record was created.
  final DateTime createdAt;

  /// Public adapter identifier used by the storefront display map.
  final String providerId;

  @override
  Map<String, Object?> serialize() => <String, Object?>{
        'provider_id': providerId,
        'amount': amount,
        'created_at': createdAt,
      };

  @override
  Map<String, Object?> toJson() => serialize();
}
