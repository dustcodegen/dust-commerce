import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_sales_channel/model.dart';
import 'package:commerce_server/src/features/admin_sales_channel/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of merchant-visible sales-channel choices.
Future<Result<AdminSalesChannelDetailListResponse, SqlxError>>
    listAdminSalesChannels(
  AdminSalesChannelRepository salesChannels, {
  required String query,
  required int limit,
  required int offset,
}) async {
  final normalized = query.trim();
  final rows = await salesChannels.list(normalized, limit, offset);
  if (rows case Err(:final error)) return Err(error);
  final count = await salesChannels.count(normalized);
  if (count case Err(:final error)) return Err(error);
  return Ok(AdminSalesChannelDetailListResponse(
    salesChannels:
        (rows as Ok<List<AdminSalesChannelDetailResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

/// Reads a product's explicit channel allowlist or [None] when it is unknown.
Future<Result<Option<AdminSalesChannelListResponse>, SqlxError>>
    readAdminProductSalesChannels(
  AdminSalesChannelRepository salesChannels,
  String productId,
) async {
  final exists = await salesChannels.activeProductCount(productId);
  if (exists case Err(:final error)) return Err(error);
  if ((exists as Ok<int, SqlxError>).value == 0) return const Ok(None());
  final rows = await salesChannels.listForProduct(productId);
  if (rows case Err(:final error)) return Err(error);
  final channels =
      (rows as Ok<List<AdminSalesChannelResponse>, SqlxError>).value;
  return Ok(Some(AdminSalesChannelListResponse(
    salesChannels: channels,
    count: channels.length,
    limit: channels.length,
    offset: 0,
  )));
}

/// Business reason a channel selection could not replace product availability.
enum AdminProductSalesChannelUpdateFailure {
  /// The routed product does not exist or has been soft-deleted.
  notFound,

  /// The selection is duplicated, malformed, or contains an unknown channel.
  invalid,

  /// Persistence failed before a complete replacement could commit.
  internal,
}

/// Atomically replaces one product's complete sales-channel selection.
Future<
        Result<AdminSalesChannelListResponse,
            AdminProductSalesChannelUpdateFailure>>
    replaceAdminProductSalesChannels(
  CommerceDatabase database,
  String productId,
  AdminUpdateProductSalesChannels input, {
  required String Function() nextId,
}) async {
  final transaction =
      await database.transaction<_ProductSalesChannelUpdateOutcome>((tx) async {
    final ids = input.salesChannelIds;
    final uniqueIds = ids.toSet();
    if (ids.length > 1000 ||
        uniqueIds.length != ids.length ||
        ids.any((id) => id.isEmpty || id.trim() != id)) {
      return const Ok(_ProductSalesChannelRejected(
        AdminProductSalesChannelUpdateFailure.invalid,
      ));
    }

    final repository = AdminSalesChannelRepository(tx);
    final productCount = await repository.activeProductCount(productId);
    if (productCount case Err(:final error)) return Err(error);
    if ((productCount as Ok<int, SqlxError>).value == 0) {
      return const Ok(_ProductSalesChannelRejected(
        AdminProductSalesChannelUpdateFailure.notFound,
      ));
    }
    for (final id in ids) {
      final channelCount = await repository.activeChannelCount(id);
      if (channelCount case Err(:final error)) return Err(error);
      if ((channelCount as Ok<int, SqlxError>).value != 1) {
        return const Ok(_ProductSalesChannelRejected(
          AdminProductSalesChannelUpdateFailure.invalid,
        ));
      }
    }

    final current = await repository.listForProduct(productId);
    if (current case Err(:final error)) return Err(error);
    final currentIds = {
      for (final channel
          in (current as Ok<List<AdminSalesChannelResponse>, SqlxError>).value)
        channel.id,
    };
    for (final id in currentIds.difference(uniqueIds)) {
      final removed = await repository.removeProductChannel(productId, id);
      if (removed case Err(:final error)) return Err(error);
    }
    for (final id in uniqueIds.difference(currentIds)) {
      final restored = await repository.restoreProductChannel(productId, id);
      if (restored case Err(:final error)) return Err(error);
      if ((restored as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
        final inserted = await repository.insertProductChannel(
          nextId(),
          productId,
          id,
        );
        if (inserted case Err(:final error)) return Err(error);
      }
    }

    final refreshed = await repository.listForProduct(productId);
    if (refreshed case Err(:final error)) return Err(error);
    final channels =
        (refreshed as Ok<List<AdminSalesChannelResponse>, SqlxError>).value;
    return Ok(_ProductSalesChannelsUpdated(AdminSalesChannelListResponse(
        salesChannels: channels,
        count: channels.length,
        limit: channels.length,
        offset: 0)));
  });
  return switch (transaction) {
    Ok(value: _ProductSalesChannelsUpdated(:final response)) => Ok(response),
    Ok(value: _ProductSalesChannelRejected(:final failure)) => Err(failure),
    Err() => const Err(AdminProductSalesChannelUpdateFailure.internal),
  };
}

sealed class _ProductSalesChannelUpdateOutcome {
  const _ProductSalesChannelUpdateOutcome();
}

final class _ProductSalesChannelsUpdated
    extends _ProductSalesChannelUpdateOutcome {
  const _ProductSalesChannelsUpdated(this.response);

  final AdminSalesChannelListResponse response;
}

final class _ProductSalesChannelRejected
    extends _ProductSalesChannelUpdateOutcome {
  const _ProductSalesChannelRejected(this.failure);

  final AdminProductSalesChannelUpdateFailure failure;
}
