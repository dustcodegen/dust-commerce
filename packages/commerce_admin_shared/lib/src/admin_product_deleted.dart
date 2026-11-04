import 'package:dust_dart/serde.dart';

part 'admin_product_deleted.g.dart';

/// Medusa-shaped acknowledgement for one retired merchant product.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductDeleted with _$AdminProductDeleted {
  /// Creates the explicit deletion acknowledgement.
  const AdminProductDeleted({
    required this.id,
    this.object = 'product',
    this.deleted = true,
  });

  /// Decodes the generated Admin response.
  factory AdminProductDeleted.fromJson(Map<String, Object?> json) =>
      _$AdminProductDeletedFromJson(json);

  /// Confirms that the active product was retired.
  final bool deleted;

  /// Stable retired product identifier.
  final String id;

  /// Stable Medusa resource discriminator.
  final String object;
}
