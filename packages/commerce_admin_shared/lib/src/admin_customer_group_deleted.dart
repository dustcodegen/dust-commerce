import 'package:dust_dart/serde.dart';

part 'admin_customer_group_deleted.g.dart';

/// Medusa-shaped acknowledgement for one retired customer group.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerGroupDeleted with _$AdminCustomerGroupDeleted {
  /// Creates the explicit deletion acknowledgement.
  const AdminCustomerGroupDeleted({
    required this.id,
    this.object = 'customer_group',
    this.deleted = true,
  });

  /// Decodes the generated Admin response.
  factory AdminCustomerGroupDeleted.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerGroupDeletedFromJson(json);

  /// Confirms that the active group was retired.
  final bool deleted;

  /// Stable retired customer-group identifier.
  final String id;

  /// Stable Medusa resource discriminator.
  final String object;
}
