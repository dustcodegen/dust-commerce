import 'package:commerce_server/src/features/account/model.dart';
import 'package:dust_dart/serde.dart';

part 'registration_response.g.dart';

/// Registration-only response that cannot widen the customer response.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CustomerRegistrationResponse with _$CustomerRegistrationResponse {
  /// Creates the registration response.
  const CustomerRegistrationResponse({
    required this.customer,
    required this.verificationRequired,
  });

  /// Explicit customer allowlist created by registration.
  final CustomerResponse customer;

  /// Whether sign-in waits for the emailed capability.
  final bool verificationRequired;
}
