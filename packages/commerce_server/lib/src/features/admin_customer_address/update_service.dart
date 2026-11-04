import 'dart:convert';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer/detail_repository.dart';
import 'package:commerce_server/src/features/admin_customer_address/update_repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Atomically patches one active address and returns its refreshed customer.
Future<Result<Option<AdminCustomerDetailResponse>, SqlxError>>
    updateAdminCustomerAddress(
  CommerceDatabase database,
  String customerId,
  String addressId,
  AdminUpdateCustomerAddress input,
) =>
        database.transaction<Option<AdminCustomerDetailResponse>>((tx) async {
          final updated = await AdminCustomerAddressUpdateRepository(tx).update(
            addressId,
            customerId,
            jsonEncode(input.toJson()),
          );
          if (updated case Err(:final error)) return Err(error);
          if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
            return const Ok(None());
          }

          final refreshed =
              await AdminCustomerDetailRepository(tx).find(customerId);
          return switch (refreshed) {
            Ok(value: final customer?) => Ok(Some(customer)),
            Ok(value: null) => const Ok(None()),
            Err(:final error) => Err(error),
          };
        });
