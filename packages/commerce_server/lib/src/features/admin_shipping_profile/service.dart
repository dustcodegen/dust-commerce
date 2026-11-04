import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/model.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of selectable fulfillment profiles.
Future<Result<AdminShippingProfileListResponse, SqlxError>>
    listAdminShippingProfiles(
  AdminShippingProfileRepository profiles, {
  required String query,
  required String name,
  required String type,
  required AdminDateFilter createdAt,
  required AdminDateFilter updatedAt,
  required AdminShippingProfileOrder order,
  required int limit,
  required int offset,
}) async {
  final normalized = query.trim();
  final normalizedName = name.trim();
  final normalizedType = type.trim();
  final rows = await profiles.list(
    normalized,
    normalizedName,
    normalizedType,
    _value(createdAt.greaterThan),
    _value(createdAt.greaterThanOrEqual),
    _value(createdAt.lessThan),
    _value(createdAt.lessThanOrEqual),
    _value(updatedAt.greaterThan),
    _value(updatedAt.greaterThanOrEqual),
    _value(updatedAt.lessThan),
    _value(updatedAt.lessThanOrEqual),
    order.parameter,
    limit,
    offset,
  );
  if (rows case Err(:final error)) return Err(error);
  final count = await profiles.count(
    normalized,
    normalizedName,
    normalizedType,
    _value(createdAt.greaterThan),
    _value(createdAt.greaterThanOrEqual),
    _value(createdAt.lessThan),
    _value(createdAt.lessThanOrEqual),
    _value(updatedAt.greaterThan),
    _value(updatedAt.greaterThanOrEqual),
    _value(updatedAt.lessThan),
    _value(updatedAt.lessThanOrEqual),
  );
  if (count case Err(:final error)) return Err(error);
  return Ok(AdminShippingProfileListResponse(
    shippingProfiles:
        (rows as Ok<List<AdminShippingProfileResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

String _value(Option<DateTime> value) => switch (value) {
      Some(value: final instant) => instant.toIso8601String(),
      None() => '',
    };

/// Business reason a product profile replacement could not commit.
enum AdminProductShippingProfileUpdateFailure {
  /// No active product owns the routed identifier.
  notFound,

  /// The optional profile identifier is malformed or unavailable.
  invalid,

  /// Persistence failed before the transaction could commit.
  internal,
}

/// Atomically replaces or clears one product's scalar fulfillment profile.
Future<
        Result<AdminProductShippingProfileResponse,
            AdminProductShippingProfileUpdateFailure>>
    replaceAdminProductShippingProfile(
  CommerceDatabase database,
  String productId,
  AdminUpdateProductShippingProfile input, {
  required String Function() nextId,
}) async {
  final transaction = await database
      .transaction<_ProductShippingProfileUpdateOutcome>((tx) async {
    final repository = AdminShippingProfileRepository(tx);
    final productCount = await repository.activeProductCount(productId);
    if (productCount case Err(:final error)) return Err(error);
    if ((productCount as Ok<int, SqlxError>).value == 0) {
      return const Ok(_ProductShippingProfileRejected(
        AdminProductShippingProfileUpdateFailure.notFound,
      ));
    }

    final requested = input.shippingProfileId;
    if (requested case Some(value: final id)) {
      if (id.isEmpty || id.trim() != id) {
        return const Ok(_ProductShippingProfileRejected(
          AdminProductShippingProfileUpdateFailure.invalid,
        ));
      }
      final count = await repository.activeProfileCount(id);
      if (count case Err(:final error)) return Err(error);
      if ((count as Ok<int, SqlxError>).value != 1) {
        return const Ok(_ProductShippingProfileRejected(
          AdminProductShippingProfileUpdateFailure.invalid,
        ));
      }
    }

    final current = await repository.currentForProduct(productId);
    if (current case Err(:final error)) return Err(error);
    final currentId = switch (
        (current as Ok<AdminShippingProfileResponse?, SqlxError>).value) {
      final AdminShippingProfileResponse profile => Some(profile.id),
      null => const None<String>(),
    };
    if (currentId != requested) {
      final removed = await repository.removeCurrent(productId);
      if (removed case Err(:final error)) return Err(error);
      if (requested case Some(value: final id)) {
        final restored = await repository.restore(productId, id);
        if (restored case Err(:final error)) return Err(error);
        if ((restored as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
          final inserted = await repository.insert(nextId(), productId, id);
          if (inserted case Err(:final error)) return Err(error);
        }
      }
    }

    final refreshed = await repository.currentForProduct(productId);
    if (refreshed case Err(:final error)) return Err(error);
    return Ok(_ProductShippingProfileUpdated(
      AdminProductShippingProfileResponse(
        shippingProfile:
            (refreshed as Ok<AdminShippingProfileResponse?, SqlxError>).value,
      ),
    ));
  });
  return switch (transaction) {
    Ok(value: _ProductShippingProfileUpdated(:final response)) => Ok(response),
    Ok(value: _ProductShippingProfileRejected(:final failure)) => Err(failure),
    Err() => const Err(AdminProductShippingProfileUpdateFailure.internal),
  };
}

sealed class _ProductShippingProfileUpdateOutcome {
  const _ProductShippingProfileUpdateOutcome();
}

final class _ProductShippingProfileUpdated
    extends _ProductShippingProfileUpdateOutcome {
  const _ProductShippingProfileUpdated(this.response);

  final AdminProductShippingProfileResponse response;
}

final class _ProductShippingProfileRejected
    extends _ProductShippingProfileUpdateOutcome {
  const _ProductShippingProfileRejected(this.failure);

  final AdminProductShippingProfileUpdateFailure failure;
}
