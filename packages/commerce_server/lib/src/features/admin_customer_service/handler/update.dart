import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer_service/deps.dart';
import 'package:commerce_server/src/features/admin_customer_service/model.dart';
import 'package:commerce_server/src/features/admin_customer_service/service/update.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const StrictJsonExtractable<AdminUpdateCustomerService> _body =
    StrictJsonExtractable(
  AdminUpdateCustomerService.fromJson,
  fields: {'status'},
);

/// `POST /admin/customer-service/{id}` — updates one triage lifecycle.
Future<Result<AdminCustomerServiceResponse, Rejection>>
    updateAdminCustomerServiceHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A support request id is required'));
  }
  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminCustomerServiceDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerServiceDeps, Rejection>).value;
  final input = (decoded as Ok<AdminUpdateCustomerService, Rejection>).value;
  final result = await updateAdminCustomerService(deps.database, id, input);
  return switch (result) {
    Ok(value: Some(:final value)) => Ok(value),
    Ok(value: None()) => Err(Rejection.notFound('Support request "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}
