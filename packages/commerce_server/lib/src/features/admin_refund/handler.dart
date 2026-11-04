import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_refund/failure.dart';
import 'package:commerce_server/src/features/admin_refund/payment_model.dart';
import 'package:commerce_server/src/features/admin_refund/payment_service.dart';
import 'package:commerce_server/src/features/admin_refund/reason_model.dart';
import 'package:commerce_server/src/features/admin_refund/reason_repository.dart';
import 'package:commerce_server/src/features/admin_refund/reason_service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const JsonExtractable<AdminRefundPayment> _body =
    JsonExtractable(AdminRefundPayment.fromJson);

/// `GET /admin/refund-reasons` lists active merchant choices.
Future<Result<AdminRefundReasonListResponse, Rejection>>
    listAdminRefundReasonsHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminOrderDeps(request);
  if (state case Err(:final error)) return Err(error);
  final query = request.requestedUri.queryParameters;
  final limit = int.tryParse(query['limit'] ?? '') ?? defaultLimit;
  final offset = int.tryParse(query['offset'] ?? '') ?? 0;
  final deps = (state as Ok<AdminOrderDeps, Rejection>).value;
  final result = await listAdminRefundReasons(
    AdminRefundReasonRepository(deps.database.connection),
    query: query['q'] ?? '',
    limit: limit.clamp(1, 1000),
    offset: offset < 0 ? 0 : offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

/// `POST /admin/payments/{id}/refund` records one independent refund.
Future<Result<AdminRefundedPaymentResponse, Rejection>>
    refundAdminPaymentHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A payment id is required'));
  }
  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminOrderDeps(request);
  if (state case Err(:final error)) return Err(error);
  final admin = (actor as Ok<AuthenticatedAdmin, Rejection>).value;
  final deps = (state as Ok<AdminOrderDeps, Rejection>).value;
  final result = await refundAdminPayment(
    deps,
    id,
    admin.user.id,
    (decoded as Ok<AdminRefundPayment, Rejection>).value,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: AdminPaymentRefundRejected(:final failure)) => switch (failure) {
        AdminPaymentRefundFailure.unavailable =>
          Err(Rejection.notFound('Payment')),
        AdminPaymentRefundFailure.providerUnavailable =>
          const Err(Rejection.status(503, 'Payment provider unavailable')),
        AdminPaymentRefundFailure.notCaptured =>
          const Err(Rejection.status(422, 'Payment is not captured')),
        AdminPaymentRefundFailure.invalidAmount => const Err(
            Rejection.status(422, 'Refund amount exceeds available funds'),
          ),
        AdminPaymentRefundFailure.unavailableReason => const Err(
            Rejection.status(422, 'Refund reason is unavailable'),
          ),
        AdminPaymentRefundFailure.invalidPayment =>
          const Err(Rejection.conflict('Payment requires reconciliation')),
      },
    Err(error: AdminPaymentRefundStorage()) => const Err(Rejection.internal()),
  };
}
