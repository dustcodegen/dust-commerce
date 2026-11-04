import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer/detail_repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Reads one active customer detail, or [None] when it is unavailable.
Future<Result<Option<AdminCustomerDetailResponse>, SqlxError>>
    readAdminCustomer(
  AdminCustomerDetailRepository customers,
  String id,
) async {
  final result = await customers.find(id);
  return switch (result) {
    Ok(:final value) => Ok(optionOf(value)),
    Err(:final error) => Err(error),
  };
}
