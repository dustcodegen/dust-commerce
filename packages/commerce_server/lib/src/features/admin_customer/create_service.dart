import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer/create_failure.dart';
import 'package:commerce_server/src/features/admin_customer/create_repository.dart';
import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:dust_dart/db.dart';

/// Creates a non-authenticating customer profile from allowlisted Admin input.
Future<Result<AdminCustomerDetailResponse, AdminCreateCustomerError>>
    createAdminCustomer(
  AdminCustomerCreateRepository customers,
  AdminCreateCustomer input, {
  required String Function() nextId,
}) async {
  final result = await customers.insert(
    nextId(),
    input.email,
    input.companyNameValue,
    input.firstNameValue,
    input.lastNameValue,
    input.phoneValue,
  );
  return switch (result) {
    Ok(value: final customer?) => Ok(customer),
    Ok(value: null) => const Err(AdminCreateCustomerRejected(
        AdminCreateCustomerFailure.emailConflict,
      )),
    Err(:final error) => Err(AdminCreateCustomerStorage(error)),
  };
}
