import 'package:dust_dart/serde.dart';

part 'admin_product_organization.g.dart';

/// Complete replacement of the product's reusable classification.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateProductOrganization
    with _$AdminUpdateProductOrganization {
  /// Creates an assignment; `null` intentionally clears the current type.
  const AdminUpdateProductOrganization({required this.typeId});

  /// Decodes one generated Admin organization request.
  factory AdminUpdateProductOrganization.fromJson(
    Map<String, Object?> json,
  ) =>
      _$AdminUpdateProductOrganizationFromJson(json);

  /// Stable active product-type identifier, or `null` to remove the type.
  @Validate(length: Length(max: 255), message: 'Choose a valid product type')
  final String? typeId;
}
