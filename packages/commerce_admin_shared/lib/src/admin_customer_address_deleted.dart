import 'package:commerce_admin_shared/src/admin_customer_detail.dart';
import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_address_deleted.g.dart';

/// Explicit Medusa acknowledgement for one removed customer address.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerAddressDeleted with _$AdminCustomerAddressDeleted {
  /// Creates an acknowledgement with its optional refreshed parent.
  const AdminCustomerAddressDeleted({
    required this.id,
    required this.parentValue,
    this.object = 'customer_address',
    this.deleted = true,
  });

  /// Decodes the generated Admin response.
  factory AdminCustomerAddressDeleted.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerAddressDeletedFromJson(json);

  /// Confirms that the active address was removed.
  final bool deleted;

  /// Stable removed address identifier.
  final String id;

  /// Stable Medusa resource discriminator.
  final String object;

  /// Nullable wire backing for [parent].
  @SerDe(rename: 'parent')
  final AdminCustomerDetail? parentValue;

  /// Refreshed customer when the server includes the parent resource.
  Option<AdminCustomerDetail> get parent => adminOptionOf(parentValue);
}
