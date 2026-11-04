import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer_group/deps.dart';
import 'package:commerce_server/src/features/admin_customer_group/detail_response.dart';
import 'package:commerce_server/src/features/admin_customer_group/service/update/membership.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminBatchCustomerGroupCustomers> _membershipBody =
    ValidatedExtractable(
  StrictJsonExtractable<AdminBatchCustomerGroupCustomers>(
    AdminBatchCustomerGroupCustomers.fromJson,
    fields: {'add', 'remove'},
  ),
);

/// `POST /admin/customer-groups/{id}/customers` — updates active memberships.
Future<Result<AdminCustomerGroupDetailResult, Rejection>>
    updateAdminCustomerGroupMembershipsHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A customer-group id is required'));
  }
  final decoded = await _membershipBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminCustomerGroupDeps(request);
  if (state case Err(:final error)) return Err(error);
  final admin = (actor as Ok<AuthenticatedAdmin, Rejection>).value;
  final input =
      (decoded as Ok<AdminBatchCustomerGroupCustomers, Rejection>).value;
  final deps = (state as Ok<AdminCustomerGroupDeps, Rejection>).value;
  return switch (await updateAdminCustomerGroupMemberships(
    deps.database,
    id,
    input,
    createdBy: admin.user.id,
    nextId: deps.clock.nextId,
  )) {
    Ok(value: Some(:final value)) => Ok(value),
    Ok(value: None()) => Err(Rejection.notFound('Customer group "$id"')),
    Err(error: AdminCustomerGroupMembershipFailure.invalidBatch) =>
      const Err(Rejection.unprocessable({
        'customers': ['Add or remove between 1 and 500 unique customers'],
      })),
    Err(error: AdminCustomerGroupMembershipFailure.invalidCustomers) =>
      const Err(Rejection.unprocessable({
        'customers': ['Every customer must exist and be active'],
      })),
    Err(error: AdminCustomerGroupMembershipFailure.database) =>
      const Err(Rejection.internal()),
  };
}
