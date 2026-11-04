import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/create_fulfillment_failure.dart';
import 'package:commerce_server/src/features/admin_order/create_fulfillment_service.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:dust_server/server.dart';

const JsonExtractable<AdminCreateFulfillment> _body =
    JsonExtractable(AdminCreateFulfillment.fromJson);

/// `POST /admin/orders/{id}/fulfillments` creates one atomic fulfillment.
Future<Result<AdminOrderDetailResponse, Rejection>>
    createAdminOrderFulfillmentHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('An order id is required'));
  }
  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminOrderDeps(request);
  if (state case Err(:final error)) return Err(error);
  final admin = (actor as Ok<AuthenticatedAdmin, Rejection>).value;
  final deps = (state as Ok<AdminOrderDeps, Rejection>).value;
  final result = await createAdminOrderFulfillment(
    deps,
    id,
    admin.user.id,
    (decoded as Ok<AdminCreateFulfillment, Rejection>).value,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminCreateFulfillmentRejected(
        failure: AdminCreateFulfillmentFailure.unavailable,
      )
    ) =>
      Err(Rejection.notFound('Order "$id"')),
    Err(
      error: AdminCreateFulfillmentRejected(
        failure: AdminCreateFulfillmentFailure.invalid,
      )
    ) =>
      const Err(Rejection.status(422, 'Fulfillment command is invalid')),
    Err(
      error: AdminCreateFulfillmentRejected(
        failure: AdminCreateFulfillmentFailure.notificationUnavailable,
      )
    ) =>
      const Err(Rejection.status(503, 'Fulfillment notification unavailable')),
    Err(error: AdminCreateFulfillmentStorage()) =>
      const Err(Rejection.internal()),
  };
}
