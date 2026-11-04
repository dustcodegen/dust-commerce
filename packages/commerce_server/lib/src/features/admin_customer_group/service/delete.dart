import 'package:commerce_admin_shared/commerce_admin_shared.dart'
    show AdminCustomerGroupDeleted;
import 'package:commerce_server/src/features/admin_customer_group/repository/delete.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Atomically retires one active customer group and all active memberships.
Future<Result<Option<AdminCustomerGroupDeleted>, SqlxError>>
    deleteAdminCustomerGroup(CommerceDatabase database, String id) =>
        database.transaction<Option<AdminCustomerGroupDeleted>>((tx) async {
          final deletes = AdminCustomerGroupDeleteRepository(tx);
          final group = await deletes.group(id);
          if (group case Err(:final error)) return Err(error);
          if ((group as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
            return const Ok(None());
          }

          final memberships = await deletes.memberships(id);
          if (memberships case Err(:final error)) return Err(error);
          return Ok(Some(AdminCustomerGroupDeleted(id: id)));
        });
