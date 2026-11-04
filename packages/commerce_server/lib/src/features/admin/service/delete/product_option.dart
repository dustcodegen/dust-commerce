import 'package:commerce_server/src/features/admin/product_option_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a product option could not be retired.
enum AdminDeleteProductOptionFailure {
  /// No active option owns the identifier.
  notFound,

  /// One or more active products still expose the option.
  inUse,
}

/// Atomically retires one option and its values when no product uses it.
Future<Result<Result<void, AdminDeleteProductOptionFailure>, SqlxError>>
    deleteAdminProductOption(
  CommerceDatabase database,
  String optionId,
) =>
        database.transaction((tx) async {
          final reads = AdminProductOptionRepository(tx);
          final found = await reads.findById(optionId);
          if (found case Err(:final error)) return Err(error);
          final option = optionOf(
            (found as Ok<AdminProductOptionDetailResponse?, SqlxError>).value,
          );
          if (option case None()) {
            return const Ok(Err(AdminDeleteProductOptionFailure.notFound));
          }

          final deletes = AdminProductOptionDeleteRepository(tx);
          final links = await deletes.linkedProductCount(optionId);
          if (links case Err(:final error)) return Err(error);
          if ((links as Ok<int, SqlxError>).value > 0) {
            return const Ok(Err(AdminDeleteProductOptionFailure.inUse));
          }

          final values = await deletes.retireValues(optionId);
          if (values case Err(:final error)) return Err(error);
          final retired = await deletes.retireOption(optionId);
          if (retired case Err(:final error)) return Err(error);
          return (retired as Ok<ExecResult, SqlxError>).value.rowsAffected == 1
              ? const Ok(Ok(null))
              : const Ok(Err(AdminDeleteProductOptionFailure.notFound));
        });
