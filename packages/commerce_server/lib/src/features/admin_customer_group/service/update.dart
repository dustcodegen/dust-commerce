import 'package:commerce_admin_shared/commerce_admin_shared.dart'
    show AdminUpdateCustomerGroup;
import 'package:commerce_server/src/features/admin_customer_group/detail_response.dart';
import 'package:commerce_server/src/features/admin_customer_group/repository/read.dart';
import 'package:commerce_server/src/features/admin_customer_group/repository/update.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Atomically renames one active group and returns its refreshed detail.
Future<Result<Option<AdminCustomerGroupDetailResult>, SqlxError>>
    updateAdminCustomerGroup(
  CommerceDatabase database,
  String id,
  AdminUpdateCustomerGroup input,
) =>
        database
            .transaction<Option<AdminCustomerGroupDetailResult>>((tx) async {
          final updated = await AdminCustomerGroupUpdateRepository(tx)
              .update(id, input.name);
          if (updated case Err(:final error)) return Err(error);
          if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
            return const Ok(None());
          }

          final refreshed =
              await AdminCustomerGroupDetailRepository(tx).find(id);
          return switch (refreshed) {
            Ok(value: final value?) => Ok(Some(AdminCustomerGroupDetailResult(
                customerGroup: value,
              ))),
            Ok(value: null) => const Ok(None()),
            Err(:final error) => Err(error),
          };
        });
