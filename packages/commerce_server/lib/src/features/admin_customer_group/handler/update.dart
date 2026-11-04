import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer_group/deps.dart';
import 'package:commerce_server/src/features/admin_customer_group/detail_response.dart';
import 'package:commerce_server/src/features/admin_customer_group/service/update.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminUpdateCustomerGroup> _customerGroupBody =
    ValidatedExtractable(
  StrictJsonExtractable<AdminUpdateCustomerGroup>(
    AdminUpdateCustomerGroup.fromJson,
    fields: {'name'},
  ),
);

/// `POST /admin/customer-groups/{id}` — replaces the merchant-facing name.
Future<Result<AdminCustomerGroupDetailResult, Rejection>>
    updateAdminCustomerGroupHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A customer-group id is required'));
  }
  final decoded = await _customerGroupBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminCustomerGroupDeps(request);
  if (state case Err(:final error)) return Err(error);
  final input = (decoded as Ok<AdminUpdateCustomerGroup, Rejection>).value;
  final deps = (state as Ok<AdminCustomerGroupDeps, Rejection>).value;
  final result = await updateAdminCustomerGroup(deps.database, id, input);
  return switch (result) {
    Ok(value: Some(:final value)) => Ok(value),
    Ok(value: None()) => Err(Rejection.notFound('Customer group "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}
