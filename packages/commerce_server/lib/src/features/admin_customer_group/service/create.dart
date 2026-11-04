import 'dart:convert';

import 'package:commerce_admin_shared/commerce_admin_shared.dart'
    show AdminCreateCustomerGroup;
import 'package:commerce_server/src/features/admin_customer_group/create_failure.dart';
import 'package:commerce_server/src/features/admin_customer_group/create_response.dart';
import 'package:commerce_server/src/features/admin_customer_group/repository/create.dart';
import 'package:dust_dart/db.dart';

/// Creates one merchant-owned customer segment.
Future<Result<AdminCustomerGroupCreateResult, AdminCustomerGroupCreateError>>
    createAdminCustomerGroup(
  AdminCustomerGroupCreateRepository groups,
  AdminCreateCustomerGroup input, {
  required String createdBy,
  required String Function() nextId,
}) async {
  final metadata = switch (input.metadataValue) {
    final value? => jsonEncode(value),
    null => null,
  };
  final result = await groups.insert(
    nextId(),
    input.name,
    createdBy,
    metadata,
  );
  return switch (result) {
    Ok(value: final group?) => Ok(AdminCustomerGroupCreateResult(
        customerGroup: group,
      )),
    Ok(value: null) => const Err(AdminCustomerGroupCreateRejected(
        AdminCustomerGroupCreateFailure.nameConflict,
      )),
    Err(:final error) => Err(AdminCustomerGroupCreateStorage(error)),
  };
}
