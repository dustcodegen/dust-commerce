import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:dust_dart/serde.dart';

part 'delete_response.g.dart';

/// Direct server response matching Medusa's delete-with-parent shape.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerAddressDeleteResponse
    with _$AdminCustomerAddressDeleteResponse {
  /// Creates a deletion acknowledgement with its refreshed parent.
  const AdminCustomerAddressDeleteResponse({
    required this.id,
    required this.parent,
    this.object = 'customer_address',
    this.deleted = true,
  });

  /// Confirms that the active address was removed.
  final bool deleted;

  /// Stable removed address identifier.
  final String id;

  /// Stable Medusa resource discriminator.
  final String object;

  /// Refreshed direct customer projection after deletion.
  final AdminCustomerDetailResponse parent;
}
