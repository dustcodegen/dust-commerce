import 'package:dust_dart/serde.dart';

part 'admin_customer_deleted.g.dart';

/// Medusa-shaped acknowledgement for one removed customer account.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerDeleted with _$AdminCustomerDeleted {
  /// Creates the explicit deletion acknowledgement.
  const AdminCustomerDeleted({
    required this.id,
    this.object = 'customer',
    this.deleted = true,
  });

  /// Decodes the generated Admin response.
  factory AdminCustomerDeleted.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerDeletedFromJson(json);

  /// Confirms that the active customer and account boundary were removed.
  final bool deleted;

  /// Stable removed customer identifier.
  final String id;

  /// Stable Medusa resource discriminator.
  final String object;
}
