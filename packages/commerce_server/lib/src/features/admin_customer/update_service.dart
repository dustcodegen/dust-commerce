import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer/detail_repository.dart';
import 'package:commerce_server/src/features/admin_customer/update_failure.dart';
import 'package:commerce_server/src/features/admin_customer/update_outcome.dart';
import 'package:commerce_server/src/features/admin_customer/update_repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Atomically replaces one active customer's editable contact fields.
Future<Result<AdminCustomerDetailResponse, AdminUpdateCustomerError>>
    updateAdminCustomer(
  CommerceDatabase database,
  String id,
  AdminUpdateCustomer input,
) async {
  final transaction =
      await database.transaction<AdminUpdateCustomerOutcome>((tx) async {
    final details = AdminCustomerDetailRepository(tx);
    final currentResult = await details.find(id);
    if (currentResult case Err(:final error)) return Err(error);
    final current =
        (currentResult as Ok<AdminCustomerDetailResponse?, SqlxError>).value;
    if (current == null) {
      return const Ok(
        AdminCustomerUpdateDenied(AdminUpdateCustomerFailure.notFound),
      );
    }
    final requestedEmail = input.emailValue;
    if (!current.hasAccount && requestedEmail == null) {
      return const Ok(
        AdminCustomerUpdateDenied(AdminUpdateCustomerFailure.emailRequired),
      );
    }
    if (current.hasAccount &&
        requestedEmail != null &&
        requestedEmail.toLowerCase() != current.email?.toLowerCase()) {
      return const Ok(
        AdminCustomerUpdateDenied(AdminUpdateCustomerFailure.registeredEmail),
      );
    }
    final updated = await AdminCustomerUpdateRepository(tx).update(
      id,
      requestedEmail,
      input.companyNameValue,
      input.firstNameValue,
      input.lastNameValue,
      input.phoneValue,
    );
    if (updated case Err(:final error)) return Err(error);
    if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
      return const Ok(
        AdminCustomerUpdateDenied(AdminUpdateCustomerFailure.emailConflict),
      );
    }
    final refreshed = await details.find(id);
    if (refreshed case Err(:final error)) return Err(error);
    final customer =
        (refreshed as Ok<AdminCustomerDetailResponse?, SqlxError>).value;
    return customer == null
        ? const Ok(
            AdminCustomerUpdateDenied(AdminUpdateCustomerFailure.notFound),
          )
        : Ok(AdminCustomerUpdated(customer));
  });
  return switch (transaction) {
    Ok(value: AdminCustomerUpdated(:final customer)) => Ok(customer),
    Ok(value: AdminCustomerUpdateDenied(:final failure)) =>
      Err(AdminUpdateCustomerRejected(failure)),
    Err(:final error) => Err(AdminUpdateCustomerStorage(error)),
  };
}
