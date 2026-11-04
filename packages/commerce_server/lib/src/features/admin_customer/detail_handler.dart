import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_customer/deps.dart';
import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer/detail_service.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/customers/{id}` — reads one complete customer profile.
Future<Result<AdminCustomerDetailResponse, Rejection>> readAdminCustomerHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A customer id is required'));
  }
  final state = await adminCustomerDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminCustomerDeps, Rejection>).value;
  final result = await readAdminCustomer(deps.details, id);
  return switch (result) {
    Ok(value: Some(value: final customer)) => Ok(customer),
    Ok(value: None()) => Err(Rejection.notFound('Customer "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}
