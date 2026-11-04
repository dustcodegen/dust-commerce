import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:commerce_server/src/features/admin_order/detail_repository.dart';
import 'package:commerce_server/src/features/admin_order/mark_delivered_failure.dart';
import 'package:commerce_server/src/features/admin_order/mark_delivered_model.dart';
import 'package:commerce_server/src/features/admin_order/mark_delivered_outcome.dart';
import 'package:commerce_server/src/features/admin_order/mark_delivered_repository.dart';
import 'package:dust_dart/db.dart';

/// Atomically marks one active fulfillment delivered and refreshes the order.
Future<Result<AdminOrderDetailResponse, AdminMarkDeliveredError>>
    markAdminOrderFulfillmentDelivered(
  AdminOrderDeps deps,
  String orderId,
  String fulfillmentId,
  AdminMarkFulfillmentDelivered body,
) async {
  if (!body.noNotification) {
    return const Err(AdminMarkDeliveredRejected(
      AdminMarkDeliveredFailure.notificationUnavailable,
    ));
  }
  if (!_validId(orderId) || !_validId(fulfillmentId)) {
    return const Err(AdminMarkDeliveredRejected(
      AdminMarkDeliveredFailure.invalid,
    ));
  }
  final persisted = await deps.serialWrite(
    () => deps.database.transaction<AdminMarkDeliveredOutcome>(
      (tx) => _persist(
        AdminMarkDeliveredRepository(tx),
        AdminOrderDetailRepository(tx),
        orderId,
        fulfillmentId,
      ),
    ),
  );
  return switch (persisted) {
    Ok(value: AdminMarkDeliveredReady(:final response)) => Ok(response),
    Ok(value: AdminMarkDeliveredDenied(:final failure)) =>
      Err(AdminMarkDeliveredRejected(failure)),
    Err(:final error) => Err(AdminMarkDeliveredStorage(error)),
  };
}

bool _validId(String value) => value.isNotEmpty && value.trim() == value;

Future<Result<AdminMarkDeliveredOutcome, SqlxError>> _persist(
  AdminMarkDeliveredRepository writes,
  AdminOrderDetailRepository details,
  String orderId,
  String fulfillmentId,
) async {
  final targetResult = await writes.target(orderId, fulfillmentId);
  if (targetResult case Err(:final error)) return Err(error);
  final target = (targetResult as Ok<AdminDeliveryTarget?, SqlxError>).value;
  if (target == null) return const Ok(_unavailable);
  if (target.canceled || target.delivered) return const Ok(_invalid);

  final updated = await writes.markDelivered(orderId, fulfillmentId);
  if (updated case Err(:final error)) return Err(error);
  if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
    return const Ok(_invalid);
  }
  final refreshed = await details.find(orderId);
  if (refreshed case Err(:final error)) return Err(error);
  final response =
      (refreshed as Ok<AdminOrderDetailResponse?, SqlxError>).value;
  return response == null
      ? Err(SqlxError.decode('Delivered order could not be read'))
      : Ok(AdminMarkDeliveredReady(response));
}

const _unavailable = AdminMarkDeliveredDenied(
  AdminMarkDeliveredFailure.unavailable,
);
const _invalid = AdminMarkDeliveredDenied(AdminMarkDeliveredFailure.invalid);
