import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_order/create_fulfillment_failure.dart';
import 'package:commerce_server/src/features/admin_order/create_fulfillment_model.dart';
import 'package:commerce_server/src/features/admin_order/create_fulfillment_outcome.dart';
import 'package:commerce_server/src/features/admin_order/create_fulfillment_repository.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_repository.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:dust_dart/db.dart';

/// Atomically creates a fulfillment and returns the refreshed Admin order.
Future<Result<AdminOrderDetailResponse, AdminCreateFulfillmentError>>
    createAdminOrderFulfillment(
  AdminOrderDeps deps,
  String orderId,
  String adminId,
  AdminCreateFulfillment body,
) async {
  if (!body.noNotification) {
    return const Err(
      AdminCreateFulfillmentRejected(
        AdminCreateFulfillmentFailure.notificationUnavailable,
      ),
    );
  }
  if (!_valid(orderId, adminId, body)) {
    return const Err(
      AdminCreateFulfillmentRejected(AdminCreateFulfillmentFailure.invalid),
    );
  }
  final fulfillmentId = deps.nextId();
  final itemIds = [for (final _ in body.items) deps.nextId()];
  final persisted = await deps.serialWrite(
    () => deps.database.transaction<AdminCreateFulfillmentOutcome>(
      (tx) => _persist(
        AdminCreateFulfillmentRepository(tx),
        AdminOrderDetailRepository(tx),
        orderId,
        adminId,
        fulfillmentId,
        itemIds,
        body,
      ),
    ),
  );
  return switch (persisted) {
    Ok(value: AdminCreateFulfillmentReady(:final response)) => Ok(response),
    Ok(value: AdminCreateFulfillmentDenied(:final failure)) =>
      Err(AdminCreateFulfillmentRejected(failure)),
    Err(:final error) => Err(AdminCreateFulfillmentStorage(error)),
  };
}

bool _valid(String orderId, String adminId, AdminCreateFulfillment body) {
  if (orderId.isEmpty || adminId.isEmpty) return false;
  if (body.items.isEmpty || body.items.length > 100) return false;
  if (body.locationId.isEmpty || body.locationId.trim() != body.locationId) {
    return false;
  }
  final optionId = body.shippingOptionIdValue;
  if (optionId == null || optionId.isEmpty || optionId.trim() != optionId) {
    return false;
  }
  final ids = <String>{};
  return body.items.every((item) =>
      item.id.isNotEmpty &&
      item.id.trim() == item.id &&
      item.quantity > 0 &&
      ids.add(item.id));
}

Future<Result<AdminCreateFulfillmentOutcome, SqlxError>> _persist(
  AdminCreateFulfillmentRepository writes,
  AdminOrderDetailRepository details,
  String orderId,
  String adminId,
  String fulfillmentId,
  List<String> itemIds,
  AdminCreateFulfillment body,
) async {
  final count = await writes.orderCount(orderId);
  if (count case Err(:final error)) return Err(error);
  if ((count as Ok<int, SqlxError>).value != 1) {
    return const Ok(
      AdminCreateFulfillmentDenied(
        AdminCreateFulfillmentFailure.unavailable,
      ),
    );
  }
  final selectedContext = await writes.context(
    orderId,
    body.locationId,
    body.shippingOptionIdValue!,
  );
  if (selectedContext case Err(:final error)) return Err(error);
  final context =
      (selectedContext as Ok<AdminFulfillmentContext?, SqlxError>).value;
  if (context == null) return const Ok(_invalid);

  final selected =
      <({AdminCreateFulfillmentItem item, AdminFulfillmentLine line})>[];
  for (final item in body.items) {
    final candidate = await writes.line(orderId, item.id);
    if (candidate case Err(:final error)) return Err(error);
    final line = (candidate as Ok<AdminFulfillmentLine?, SqlxError>).value;
    if (line == null || line.remaining < item.quantity) {
      return const Ok(_invalid);
    }
    selected.add((item: item, line: line));
  }
  final parent = await writes.insertFulfillment(
    fulfillmentId,
    orderId,
    body.locationId,
    context.providerId,
    body.shippingOptionIdValue!,
    adminId,
    context.data,
  );
  if (parent case Err(:final error)) return Err(error);
  if ((parent as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
    return Err(SqlxError.decode('Fulfillment parent could not be inserted'));
  }
  for (var index = 0; index < selected.length; index++) {
    final value = selected[index];
    final inserted = await writes.insertItem(
      itemIds[index],
      fulfillmentId,
      value.line.title,
      value.item.quantity,
      value.line.sku,
      value.line.barcode,
      value.item.id,
    );
    if (inserted case Err(:final error)) return Err(error);
    if ((inserted as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
      return Err(SqlxError.decode('Fulfillment item could not be inserted'));
    }
  }
  final refreshed = await details.find(orderId);
  if (refreshed case Err(:final error)) return Err(error);
  final response =
      (refreshed as Ok<AdminOrderDetailResponse?, SqlxError>).value;
  return response == null
      ? Err(SqlxError.decode('Created fulfillment order could not be read'))
      : Ok(AdminCreateFulfillmentReady(response));
}

const _invalid = AdminCreateFulfillmentDenied(
  AdminCreateFulfillmentFailure.invalid,
);
