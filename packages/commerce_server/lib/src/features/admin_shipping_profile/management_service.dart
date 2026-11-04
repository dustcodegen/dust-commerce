import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/management_repository.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/model.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Business reason a shipping-profile settings operation failed.
enum AdminShippingProfileManagementFailure {
  /// The normalized name or type is outside the accepted boundary.
  invalid,

  /// Another active profile already owns the normalized name.
  nameConflict,

  /// No active profile owns the routed identifier.
  notFound,

  /// Persistence failed before the operation could commit.
  internal,
}

/// Reads one active shipping profile without exposing provider metadata.
Future<
    Result<AdminShippingProfileResponse,
        AdminShippingProfileManagementFailure>> readAdminShippingProfile(
  AdminShippingProfileManagementRepository profiles,
  String id,
) async {
  final result = await profiles.find(id);
  return switch (result) {
    Ok(:final AdminShippingProfileResponse value) => Ok(value),
    Ok(value: null) =>
      const Err(AdminShippingProfileManagementFailure.notFound),
    Err() => const Err(AdminShippingProfileManagementFailure.internal),
  };
}

/// Creates one normalized shipping profile with database-owned timestamps.
Future<
    Result<AdminShippingProfileResponse,
        AdminShippingProfileManagementFailure>> createAdminShippingProfile(
  AdminShippingProfileManagementRepository profiles,
  AdminCreateShippingProfile input, {
  required String Function() nextId,
}) async {
  final name = input.name.trim();
  final type = input.type.trim();
  if (name.isEmpty || name.length > 255 || type.isEmpty || type.length > 255) {
    return const Err(AdminShippingProfileManagementFailure.invalid);
  }
  final result = await profiles.insert(nextId(), name, type);
  return switch (result) {
    Ok(:final AdminShippingProfileResponse value) => Ok(value),
    Ok(value: null) =>
      const Err(AdminShippingProfileManagementFailure.nameConflict),
    Err() => const Err(AdminShippingProfileManagementFailure.internal),
  };
}

/// Atomically retires one profile and every active product assignment.
Future<Result<void, AdminShippingProfileManagementFailure>>
    deleteAdminShippingProfile(CommerceDatabase database, String id) async {
  final result = await database.transaction<_DeleteOutcome>((tx) async {
    final profiles = AdminShippingProfileManagementRepository(tx);
    final retired = await profiles.retire(id);
    if (retired case Err(:final error)) return Err(error);
    if ((retired as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
      return const Ok(_DeleteMissing());
    }
    final links = await profiles.retireProductLinks(id);
    if (links case Err(:final error)) return Err(error);
    return const Ok(_DeleteCommitted());
  });
  return switch (result) {
    Ok(value: _DeleteCommitted()) => const Ok(null),
    Ok(value: _DeleteMissing()) =>
      const Err(AdminShippingProfileManagementFailure.notFound),
    Err() => const Err(AdminShippingProfileManagementFailure.internal),
  };
}

sealed class _DeleteOutcome {
  const _DeleteOutcome();
}

final class _DeleteCommitted extends _DeleteOutcome {
  const _DeleteCommitted();
}

final class _DeleteMissing extends _DeleteOutcome {
  const _DeleteMissing();
}
