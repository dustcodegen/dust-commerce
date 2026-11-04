import 'package:commerce_shared/src/customers/customer.dart';
import 'package:dust_dart/serde.dart';

part 'customer_registration.g.dart';

/// Registration result kept separate from the reusable customer contract.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CustomerRegistrationView with _$CustomerRegistrationView {
  /// Creates a registration result.
  const CustomerRegistrationView({
    required this.customer,
    required this.verificationRequired,
  });

  /// Decodes JSON using Dust.
  factory CustomerRegistrationView.fromJson(Map<String, Object?> json) =>
      _$CustomerRegistrationViewFromJson(json);

  /// Explicit customer allowlist created by registration.
  final Customer customer;

  /// Whether sign-in waits for the emailed capability.
  final bool verificationRequired;
}
