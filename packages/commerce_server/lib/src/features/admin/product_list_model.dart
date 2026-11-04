import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/product_json.dart' as json;
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'product_list_model.g.dart';

/// One product-list response populated directly from its SQL projection.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductResponse with _$AdminProductResponse {
  /// Creates an explicitly allowlisted merchant product row.
  const AdminProductResponse({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.collectionTitle,
    required this.salesChannels,
    required this.variantCount,
    required this.status,
  });

  /// Collection label, empty when no collection is attached.
  @Sqlx(rename: 'collection_title')
  final String collectionTitle;

  /// Stable product identifier.
  final String id;

  /// Active sales channels selected as an ordered JSON array.
  @Sqlx(rename: 'sales_channels', tryFrom: _AdminProductChannelsSqlxJson())
  final List<AdminSalesChannel> salesChannels;

  /// Merchant lifecycle state.
  @SerDe(using: AdminProductLifecycleCodec())
  @Sqlx(tryFrom: _AdminProductLifecycleSqlx())
  final AdminProductLifecycle status;

  /// Primary product image URL, or an empty value.
  final String thumbnail;

  /// Merchant-facing product name.
  final String title;

  /// Number of active variants.
  @Sqlx(rename: 'variant_count')
  final int variantCount;
}

/// Product rows plus their bounded-list metadata.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductListResponse with _$AdminProductListResponse {
  /// Creates a merchant product page.
  const AdminProductListResponse({
    required this.products,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total rows matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit product summaries.
  final List<AdminProductResponse> products;
}

final class _AdminProductChannelsSqlxJson
    implements SqlxTryFrom<List<AdminSalesChannel>, String> {
  const _AdminProductChannelsSqlxJson();

  @override
  List<AdminSalesChannel> decode(String value) =>
      const json.AdminProductSalesChannelsFromJson().decode(value);
}

final class _AdminProductLifecycleSqlx
    implements SqlxTryFrom<AdminProductLifecycle, String> {
  const _AdminProductLifecycleSqlx();

  @override
  AdminProductLifecycle decode(String value) =>
      AdminProductLifecycle.values.byName(value);
}
