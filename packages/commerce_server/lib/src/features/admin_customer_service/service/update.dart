import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer_service/model.dart';
import 'package:commerce_server/src/features/admin_customer_service/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Atomically changes lifecycle and returns the refreshed direct SQLx row.
Future<Result<Option<AdminCustomerServiceResponse>, SqlxError>>
    updateAdminCustomerService(
  CommerceDatabase database,
  String id,
  AdminUpdateCustomerService input,
) =>
        database.transaction<Option<AdminCustomerServiceResponse>>((tx) async {
          final requests = AdminCustomerServiceRepository(tx);
          final status =
              const AdminCustomerServiceStatusCodec().serialize(input.status);
          final updated = await requests.updateStatus(id, status);
          if (updated case Err(:final error)) return Err(error);
          if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
            return const Ok(None());
          }
          final refreshed = await requests.find(id);
          return switch (refreshed) {
            Ok(value: final value?) => Ok(Some(value)),
            Ok(value: null) => const Ok(None()),
            Err(:final error) => Err(error),
          };
        });
