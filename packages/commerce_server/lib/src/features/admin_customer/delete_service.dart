import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer/delete_failure.dart';
import 'package:commerce_server/src/features/admin_customer/delete_model.dart';
import 'package:commerce_server/src/features/admin_customer/delete_outcome.dart';
import 'package:commerce_server/src/features/admin_customer/delete_repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Soft-deletes a customer graph and removes its authentication actor.
Future<AdminDeleteCustomerResult> deleteAdminCustomer(
  CommerceDatabase database,
  String id,
) async {
  final transaction =
      await database.transaction<AdminCustomerDeleteOutcome>((tx) async {
    final deletes = AdminCustomerDeleteRepository(tx);
    final contextResult = await deletes.find(id);
    if (contextResult case Err(:final error)) return Err(error);
    final context =
        (contextResult as Ok<AdminCustomerDeleteContext?, SqlxError>).value;
    if (context == null) {
      return const Ok(
        AdminCustomerDeleteDenied(AdminDeleteCustomerFailure.notFound),
      );
    }
    if (context.hasAccount &&
        (context.authIdentityCount != 1 || context.authIdentityId == null)) {
      return const Ok(
        AdminCustomerDeleteDenied(
          AdminDeleteCustomerFailure.inconsistentIdentity,
        ),
      );
    }
    final customer = await deletes.customer(id);
    if (customer case Err(:final error)) return Err(error);
    if ((customer as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
      return const Ok(
        AdminCustomerDeleteDenied(AdminDeleteCustomerFailure.notFound),
      );
    }
    final addresses = await deletes.addresses(id);
    if (addresses case Err(:final error)) return Err(error);

    final identityId = context.authIdentityId;
    if (context.hasAccount && identityId != null) {
      final identity = context.hasOtherActor
          ? await deletes.detachCustomer(identityId)
          : await _removeIdentity(deletes, identityId);
      if (identity case Err(:final error)) return Err(error);
    }
    return Ok(AdminCustomerDeletedOutcome(AdminCustomerDeleted(id: id)));
  });
  return switch (transaction) {
    Ok(value: AdminCustomerDeletedOutcome(:final deleted)) => Ok(deleted),
    Ok(value: AdminCustomerDeleteDenied(:final failure)) =>
      Err(AdminDeleteCustomerRejected(failure)),
    Err(:final error) => Err(AdminDeleteCustomerStorage(error)),
  };
}

Future<Result<ExecResult, SqlxError>> _removeIdentity(
  AdminCustomerDeleteRepository deletes,
  String identityId,
) async {
  for (final operation in [
    () => deletes.tokens(identityId),
    () => deletes.verification(identityId),
    () => deletes.providers(identityId),
    () => deletes.identity(identityId),
  ]) {
    final result = await operation();
    if (result case Err()) return result;
  }
  return const Ok(ExecResult(rowsAffected: 1));
}
