import 'package:dust_dart/serde.dart';

part 'admin_promotion_deleted.g.dart';

/// Medusa-shaped acknowledgement for one retired promotion.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminPromotionDeleted with _$AdminPromotionDeleted {
  /// Creates the explicit retirement acknowledgement.
  const AdminPromotionDeleted({
    required this.id,
    this.object = 'promotion',
    this.deleted = true,
  });

  /// Decodes the generated Admin response.
  factory AdminPromotionDeleted.fromJson(Map<String, Object?> json) =>
      _$AdminPromotionDeletedFromJson(json);

  /// Confirms that the active promotion was retired.
  final bool deleted;

  /// Stable retired promotion identifier.
  final String id;

  /// Stable resource discriminator.
  final String object;
}
