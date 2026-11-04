import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer/detail_repository.dart';
import 'package:commerce_server/src/features/admin_customer_address/create_failure.dart';
import 'package:commerce_server/src/features/admin_customer_address/create_outcome.dart';
import 'package:commerce_server/src/features/admin_customer_address/create_repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Atomically creates one reusable destination beneath an active customer.
Future<Result<AdminCustomerDetailResponse, AdminCreateCustomerAddressError>>
    createAdminCustomerAddress(
  CommerceDatabase database,
  String customerId,
  AdminCreateCustomerAddress input, {
  required String Function() nextId,
}) async {
  final transaction =
      await database.transaction<AdminCustomerAddressCreateOutcome>((tx) async {
    final inserted = await AdminCustomerAddressCreateRepository(tx).insert(
      nextId(),
      customerId,
      input.addressName,
      input.firstNameValue,
      input.lastNameValue,
      input.companyValue,
      input.phoneValue,
      input.line1,
      input.line2Value,
      input.cityValue,
      input.countryCode,
      input.provinceValue,
      input.postalCodeValue,
      input.isDefaultShipping ? 1 : 0,
      input.isDefaultBilling ? 1 : 0,
    );
    if (inserted case Err(:final error)) return Err(error);
    if ((inserted as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
      return const Ok(AdminCustomerAddressCreateDenied(
        AdminCreateCustomerAddressFailure.customerNotFound,
      ));
    }
    final refreshed = await AdminCustomerDetailRepository(tx).find(customerId);
    if (refreshed case Err(:final error)) return Err(error);
    final customer =
        (refreshed as Ok<AdminCustomerDetailResponse?, SqlxError>).value;
    return customer == null
        ? const Ok(AdminCustomerAddressCreateDenied(
            AdminCreateCustomerAddressFailure.customerNotFound,
          ))
        : Ok(AdminCustomerAddressCreated(customer));
  });
  return switch (transaction) {
    Ok(value: AdminCustomerAddressCreated(:final customer)) => Ok(customer),
    Ok(value: AdminCustomerAddressCreateDenied(:final failure)) =>
      Err(AdminCreateCustomerAddressRejected(failure)),
    Err(:final error) => Err(AdminCreateCustomerAddressStorage(error)),
  };
}
