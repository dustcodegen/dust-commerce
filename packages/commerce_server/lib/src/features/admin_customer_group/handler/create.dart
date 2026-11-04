import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer_group/create_failure.dart';
import 'package:commerce_server/src/features/admin_customer_group/create_response.dart';
import 'package:commerce_server/src/features/admin_customer_group/deps.dart';
import 'package:commerce_server/src/features/admin_customer_group/service/create.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminCreateCustomerGroup> _customerGroupBody =
    ValidatedExtractable(
  StrictJsonExtractable<AdminCreateCustomerGroup>(
    AdminCreateCustomerGroup.fromJson,
    fields: {'name', 'metadata'},
  ),
);

/// `POST /admin/customer-groups` — creates one merchant customer segment.
Future<Result<AdminCustomerGroupCreateResult, Rejection>>
    createAdminCustomerGroupHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final decoded = await _customerGroupBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminCustomerGroupDeps(request);
  if (state case Err(:final error)) return Err(error);
  final admin = (actor as Ok<AuthenticatedAdmin, Rejection>).value;
  final input = (decoded as Ok<AdminCreateCustomerGroup, Rejection>).value;
  final deps = (state as Ok<AdminCustomerGroupDeps, Rejection>).value;
  final result = await createAdminCustomerGroup(
    deps.creates,
    input,
    createdBy: admin.user.id,
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: AdminCustomerGroupCreateRejected()) =>
      const Err(Rejection.conflict('A customer group already uses this name')),
    Err(error: AdminCustomerGroupCreateStorage()) =>
      const Err(Rejection.internal()),
  };
}
