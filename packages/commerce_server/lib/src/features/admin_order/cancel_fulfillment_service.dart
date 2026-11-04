import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_order/cancel_fulfillment_failure.dart';
import 'package:commerce_server/src/features/admin_order/cancel_fulfillment_model.dart';
import 'package:commerce_server/src/features/admin_order/cancel_fulfillment_outcome.dart';
import 'package:commerce_server/src/features/admin_order/cancel_fulfillment_repository.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:commerce_server/src/features/admin_order/detail_repository.dart';
import 'package:dust_dart/db.dart';

/// Atomically cancels one pending fulfillment and refreshes the order.
Future<Result<AdminOrderDetailResponse, AdminCancelFulfillmentError>>
    cancelAdminOrderFulfillment(
  AdminOrderDeps deps,
  String orderId,
  String fulfillmentId,
  String adminId,
  AdminCancelFulfillment body,
) async {
  if (!body.noNotification) {
    return const Err(AdminCancelFulfillmentRejected(
      AdminCancelFulfillmentFailure.notificationUnavailable,
    ));
  }
  if (!_validId(orderId) || !_validId(fulfillmentId) || !_validId(adminId)) {
    return const Err(AdminCancelFulfillmentRejected(
      AdminCancelFulfillmentFailure.invalid,
    ));
  }
  final persisted = await deps.serialWrite(
    () => deps.database.transaction<AdminCancelFulfillmentOutcome>(
      (tx) => _persist(
        AdminCancelFulfillmentRepository(tx),
        AdminOrderDetailRepository(tx),
        orderId,
        fulfillmentId,
        adminId,
      ),
    ),
  );
  return switch (persisted) {
    Ok(value: AdminCancelFulfillmentReady(:final response)) => Ok(response),
    Ok(value: AdminCancelFulfillmentDenied(:final failure)) =>
      Err(AdminCancelFulfillmentRejected(failure)),
    Err(:final error) => Err(AdminCancelFulfillmentStorage(error)),
  };
}

bool _validId(String value) => value.isNotEmpty && value.trim() == value;

Future<Result<AdminCancelFulfillmentOutcome, SqlxError>> _persist(
  AdminCancelFulfillmentRepository writes,
  AdminOrderDetailRepository details,
  String orderId,
  String fulfillmentId,
  String adminId,
) async {
  final targetResult = await writes.target(orderId, fulfillmentId);
  if (targetResult case Err(:final error)) return Err(error);
  final target =
      (targetResult as Ok<AdminCancelFulfillmentTarget?, SqlxError>).value;
  if (target == null) return const Ok(_unavailable);
  if (target.providerId != 'manual') return const Ok(_providerUnavailable);
  if (target.canceled || target.shipped || target.delivered) {
    return const Ok(_invalid);
  }

  final canceled = await writes.cancel(orderId, fulfillmentId, adminId);
  if (canceled case Err(:final error)) return Err(error);
  if ((canceled as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
    return const Ok(_invalid);
  }
  final refreshed = await details.find(orderId);
  if (refreshed case Err(:final error)) return Err(error);
  final response =
      (refreshed as Ok<AdminOrderDetailResponse?, SqlxError>).value;
  return response == null
      ? Err(SqlxError.decode('Canceled order could not be read'))
      : Ok(AdminCancelFulfillmentReady(response));
}

const _unavailable = AdminCancelFulfillmentDenied(
  AdminCancelFulfillmentFailure.unavailable,
);
const _invalid = AdminCancelFulfillmentDenied(
  AdminCancelFulfillmentFailure.invalid,
);
const _providerUnavailable = AdminCancelFulfillmentDenied(
  AdminCancelFulfillmentFailure.providerUnavailable,
);
