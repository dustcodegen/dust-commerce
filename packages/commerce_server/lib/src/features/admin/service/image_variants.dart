import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Business reason an image-to-variant batch cannot be applied.
enum AdminBatchImageVariantsFailure {
  /// The product path does not own the active image.
  notFound,

  /// A variant is invalid, duplicated, conflicting, or owned elsewhere.
  invalidVariants,
}

/// Applies Medusa-compatible add/remove image associations atomically.
Future<
    Result<
        Result<AdminBatchImageVariantsResult, AdminBatchImageVariantsFailure>,
        SqlxError>> batchAdminImageVariants(
  CommerceDatabase database,
  String productId,
  String imageId,
  AdminBatchImageVariants input,
) =>
    database.transaction((tx) async {
      final add = input.add.toSet();
      final remove = input.remove.toSet();
      if (add.length != input.add.length ||
          remove.length != input.remove.length ||
          add.intersection(remove).isNotEmpty ||
          add.length + remove.length > 500 ||
          [...add, ...remove].any((id) => id.trim().isEmpty)) {
        return const Ok(Err(AdminBatchImageVariantsFailure.invalidVariants));
      }

      final repository = AdminProductImageVariantRepository(tx);
      final owner = await repository.imageProduct(imageId);
      if (owner case Err(:final error)) return Err(error);
      if ((owner as Ok<String?, SqlxError>).value != productId) {
        return const Ok(Err(AdminBatchImageVariantsFailure.notFound));
      }

      for (final variantId in [...add, ...remove]) {
        final variantOwner = await repository.variantProduct(variantId);
        if (variantOwner case Err(:final error)) return Err(error);
        if ((variantOwner as Ok<String?, SqlxError>).value != productId) {
          return const Ok(Err(AdminBatchImageVariantsFailure.invalidVariants));
        }
      }

      for (final variantId in add) {
        final written = await repository.add(imageId, variantId);
        if (written case Err(:final error)) return Err(error);
      }
      for (final variantId in remove) {
        final written = await repository.remove(imageId, variantId);
        if (written case Err(:final error)) return Err(error);
      }

      return Ok(Ok(AdminBatchImageVariantsResult(
        added: add.toList(growable: false),
        removed: remove.toList(growable: false),
      )));
    });
