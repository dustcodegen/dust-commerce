import 'package:commerce_admin_shared/src/admin_product.dart';
import 'package:commerce_admin_shared/src/admin_sales_channel.dart';
import 'package:dust_dart/serde.dart';

part 'admin_product_summary.g.dart';

/// One explicitly allowlisted product row in the merchant catalogue.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProduct with _$AdminProduct {
  /// Creates a merchant-facing product summary.
  const AdminProduct({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.collectionTitle,
    required this.salesChannels,
    required this.variantCount,
    required this.status,
  });

  /// Decodes the admin API response using Dust.
  factory AdminProduct.fromJson(Map<String, Object?> json) =>
      _$AdminProductFromJson(json);

  /// Collection label, empty when the product is not grouped.
  final String collectionTitle;

  /// Stable product identifier used by detail routes.
  final String id;

  /// Active channel objects shown by the Medusa-shaped list cell.
  final List<AdminSalesChannel> salesChannels;

  /// Merchant lifecycle state.
  @SerDe(using: AdminProductLifecycleCodec())
  final AdminProductLifecycle status;

  /// Primary image URL, empty when the product has no thumbnail.
  final String thumbnail;

  /// Merchant-facing product name.
  final String title;

  /// Number of active variants attached to the product.
  final int variantCount;
}

/// A bounded product page returned by the merchant API.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductList with _$AdminProductList {
  /// Creates an admin product page.
  const AdminProductList({
    required this.products,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes the generated admin response.
  factory AdminProductList.fromJson(Map<String, Object?> json) =>
      _$AdminProductListFromJson(json);

  /// Total number of products matching the query.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Products in stable server-owned order.
  final List<AdminProduct> products;
}
