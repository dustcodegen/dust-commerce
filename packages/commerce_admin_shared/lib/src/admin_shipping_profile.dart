import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_shipping_profile.g.dart';

/// Shipping-profile order values accepted by the Medusa-shaped Admin API.
enum AdminShippingProfileOrder {
  /// Profile name A to Z.
  nameAsc('name'),

  /// Profile name Z to A.
  nameDesc('-name'),

  /// Profile type A to Z.
  typeAsc('type'),

  /// Profile type Z to A.
  typeDesc('-type'),

  /// Oldest profiles first.
  createdAtAsc('created_at'),

  /// Newest profiles first.
  createdAtDesc('-created_at'),

  /// Least recently updated profiles first.
  updatedAtAsc('updated_at'),

  /// Most recently updated profiles first.
  updatedAtDesc('-updated_at');

  const AdminShippingProfileOrder(this.parameter);

  /// Stable Admin API query value.
  final String parameter;

  /// Parses one allowlisted Admin API query value.
  static Option<AdminShippingProfileOrder> parse(String parameter) {
    for (final order in values) {
      if (order.parameter == parameter) return Some(order);
    }
    return const None();
  }
}

/// Merchant input for creating one fulfillment requirement group.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateShippingProfile with _$AdminCreateShippingProfile {
  /// Creates validated shipping-profile input.
  const AdminCreateShippingProfile({required this.name, required this.type});

  /// Decodes one generated Admin request.
  factory AdminCreateShippingProfile.fromJson(Map<String, Object?> json) =>
      _$AdminCreateShippingProfileFromJson(json);

  /// Merchant-facing profile label.
  @Validate(length: Length(min: 1, max: 255), message: 'Enter a name')
  @Validate(regex: r'.*\S.*', message: 'Enter a name')
  final String name;

  /// Open fulfillment behavior classification matching Medusa.
  @Validate(length: Length(min: 1, max: 255), message: 'Enter a type')
  @Validate(regex: r'.*\S.*', message: 'Enter a type')
  final String type;
}

/// Explicit merchant-facing fulfillment profile.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminShippingProfile with _$AdminShippingProfile {
  /// Creates one profile without exposing provider metadata.
  const AdminShippingProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes the generated Admin response.
  factory AdminShippingProfile.fromJson(Map<String, Object?> json) =>
      _$AdminShippingProfileFromJson(json);

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Stable fulfillment profile identifier.
  final String id;

  /// Merchant-facing selection label.
  final String name;

  /// Open fulfillment behavior classification matching Medusa.
  final String type;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}

/// One bounded shipping-profile page from the protected Admin API.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminShippingProfileList with _$AdminShippingProfileList {
  /// Creates profile choices and paging metadata.
  const AdminShippingProfileList({
    required this.shippingProfiles,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes the generated list response.
  factory AdminShippingProfileList.fromJson(Map<String, Object?> json) =>
      _$AdminShippingProfileListFromJson(json);

  /// Total matching active profiles.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching profiles skipped.
  final int offset;

  /// Explicit fulfillment choices.
  final List<AdminShippingProfile> shippingProfiles;
}

/// Optional shipping profile currently attached to one product.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductShippingProfile with _$AdminProductShippingProfile {
  /// Creates an explicit optional assignment response.
  const AdminProductShippingProfile({required this.shippingProfileValue});

  /// Decodes the generated assignment response.
  factory AdminProductShippingProfile.fromJson(Map<String, Object?> json) =>
      _$AdminProductShippingProfileFromJson(json);

  /// Nullable JSON backing for [shippingProfile].
  @SerDe(rename: 'shipping_profile')
  final AdminShippingProfile? shippingProfileValue;

  /// Product assignment expressed without nullable business state.
  Option<AdminShippingProfile> get shippingProfile =>
      adminOptionOf(shippingProfileValue);
}

/// Replaces or clears the scalar shipping profile on one product.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateProductShippingProfile
    with _$AdminUpdateProductShippingProfile {
  /// Creates one explicit optional profile selection.
  const AdminUpdateProductShippingProfile({
    required this.shippingProfileIdValue,
  });

  /// Decodes the generated Admin request.
  factory AdminUpdateProductShippingProfile.fromJson(
    Map<String, Object?> json,
  ) =>
      _$AdminUpdateProductShippingProfileFromJson(json);

  /// Nullable JSON backing for [shippingProfileId].
  @SerDe(rename: 'shipping_profile_id')
  final String? shippingProfileIdValue;

  /// Requested assignment expressed without nullable business state.
  Option<String> get shippingProfileId => adminOptionOf(shippingProfileIdValue);
}
