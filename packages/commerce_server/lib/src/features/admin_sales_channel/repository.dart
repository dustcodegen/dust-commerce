import 'package:commerce_server/src/features/admin_sales_channel/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Read-only sales-channel discovery used by Admin order filters.
@SqlxDao()
abstract final class AdminSalesChannelRepository {
  /// Binds sales-channel list queries to [db].
  const factory AdminSalesChannelRepository(Executor db) =
      _$AdminSalesChannelRepository;

  /// Counts the same non-deleted sales-channel search result.
  @Query(r'''
SELECT count(*)
FROM sales_channels
WHERE deleted_at IS NULL
  AND ($1 = '' OR lower(name) LIKE '%' || lower($1) || '%')
''')
  Future<Result<int, SqlxError>> count(String query);

  /// Lists enabled and disabled choices for current and historical orders.
  @Query(r'''
SELECT id, name, description, is_disabled = 1 AS is_disabled,
       created_at, updated_at
FROM sales_channels
WHERE deleted_at IS NULL
  AND ($1 = '' OR lower(name) LIKE '%' || lower($1) || '%')
ORDER BY lower(name), id
LIMIT $2 OFFSET $3
''')
  Future<Result<List<AdminSalesChannelDetailResponse>, SqlxError>> list(
    String query,
    int limit,
    int offset,
  );

  /// Confirms the product exists without leaking a channel-less distinction.
  @Query(r'''
SELECT count(*)
FROM products
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> activeProductCount(String productId);

  /// Lists only active channel links for one active product.
  @Query(r'''
SELECT channel.id, channel.name
FROM product_sales_channels link
JOIN sales_channels channel ON channel.id = link.sales_channel_id
JOIN products product ON product.id = link.product_id
WHERE link.product_id = $1
  AND link.deleted_at IS NULL
  AND channel.deleted_at IS NULL
  AND product.deleted_at IS NULL
ORDER BY lower(channel.name), channel.id
''')
  Future<Result<List<AdminSalesChannelResponse>, SqlxError>> listForProduct(
    String productId,
  );

  /// Confirms that one selectable channel has not been soft-deleted.
  @Query(r'''
SELECT count(*)
FROM sales_channels
WHERE id = $1 AND deleted_at IS NULL
''')
  Future<Result<int, SqlxError>> activeChannelCount(String salesChannelId);

  /// Soft-deletes one active assignment while the database owns its timestamp.
  @Query(r'''
UPDATE product_sales_channels
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE product_id = $1 AND sales_channel_id = $2 AND deleted_at IS NULL
''')
  Future<Result<ExecResult, SqlxError>> removeProductChannel(
    String productId,
    String salesChannelId,
  );

  /// Restores the newest historical assignment instead of duplicating it.
  @Query(r'''
UPDATE product_sales_channels
SET deleted_at = NULL
WHERE id = (
  SELECT id
  FROM product_sales_channels
  WHERE product_id = $1 AND sales_channel_id = $2 AND deleted_at IS NOT NULL
  ORDER BY created_at DESC, id DESC
  LIMIT 1
)
AND NOT EXISTS (
  SELECT 1 FROM product_sales_channels active
  WHERE active.product_id = $1 AND active.sales_channel_id = $2
    AND active.deleted_at IS NULL
)
''')
  Future<Result<ExecResult, SqlxError>> restoreProductChannel(
    String productId,
    String salesChannelId,
  );

  /// Creates the first durable assignment for one product/channel pair.
  @Query(r'''
INSERT INTO product_sales_channels (id, product_id, sales_channel_id)
VALUES ($1, $2, $3)
''')
  Future<Result<ExecResult, SqlxError>> insertProductChannel(
    String id,
    String productId,
    String salesChannelId,
  );
}
