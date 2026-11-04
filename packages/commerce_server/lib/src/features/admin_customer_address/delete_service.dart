import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer/detail_repository.dart';
import 'package:commerce_server/src/features/admin_customer_address/delete_failure.dart';
import 'package:commerce_server/src/features/admin_customer_address/delete_outcome.dart';
import 'package:commerce_server/src/features/admin_customer_address/delete_repository.dart';
import 'package:commerce_server/src/features/admin_customer_address/delete_response.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Soft-deletes one address only through its active parent customer.
Future<
    Result<AdminCustomerAddressDeleteResponse,
        AdminDeleteCustomerAddressError>> deleteAdminCustomerAddress(
  CommerceDatabase database,
  String customerId,
  String addressId,
) async {
  final transaction =
      await database.transaction<AdminCustomerAddressDeleteOutcome>((tx) async {
    final deleted = await AdminCustomerAddressDeleteRepository(tx).delete(
      addressId,
      customerId,
    );
    if (deleted case Err(:final error)) return Err(error);
    if ((deleted as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
      return const Ok(AdminCustomerAddressDeleteDenied(
        AdminDeleteCustomerAddressFailure.notFound,
      ));
    }
    final refreshed = await AdminCustomerDetailRepository(tx).find(customerId);
    if (refreshed case Err(:final error)) return Err(error);
    final parent =
        (refreshed as Ok<AdminCustomerDetailResponse?, SqlxError>).value;
    return parent == null
        ? const Ok(AdminCustomerAddressDeleteDenied(
            AdminDeleteCustomerAddressFailure.notFound,
          ))
        : Ok(AdminCustomerAddressDeleted(
            AdminCustomerAddressDeleteResponse(
              id: addressId,
              parent: parent,
            ),
          ));
  });
  return switch (transaction) {
    Ok(value: AdminCustomerAddressDeleted(:final response)) => Ok(response),
    Ok(value: AdminCustomerAddressDeleteDenied(:final failure)) =>
      Err(AdminDeleteCustomerAddressRejected(failure)),
    Err(:final error) => Err(AdminDeleteCustomerAddressStorage(error)),
  };
}
