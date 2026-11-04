import 'package:commerce_server/src/features/admin_customer_group/detail_response.dart';
import 'package:commerce_server/src/features/admin_customer_group/repository/read.dart';
import 'package:dust_dart/db.dart';

/// Reads one active customer group, or [None] when it is unavailable.
Future<Result<Option<AdminCustomerGroupDetailResult>, SqlxError>>
    readAdminCustomerGroup(
  AdminCustomerGroupDetailRepository groups,
  String id,
) async {
  final result = await groups.find(id);
  return switch (result) {
    Ok(value: final value?) => Ok(Some(AdminCustomerGroupDetailResult(
        customerGroup: value,
      ))),
    Ok(value: null) => const Ok(None()),
    Err(:final error) => Err(error),
  };
}
