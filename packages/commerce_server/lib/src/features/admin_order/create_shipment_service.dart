import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_order/create_shipment_failure.dart';
import 'package:commerce_server/src/features/admin_order/create_shipment_model.dart';
import 'package:commerce_server/src/features/admin_order/create_shipment_outcome.dart';
import 'package:commerce_server/src/features/admin_order/create_shipment_repository.dart';
import 'package:commerce_server/src/features/admin_order/deps.dart';
import 'package:commerce_server/src/features/admin_order/detail_model.dart';
import 'package:commerce_server/src/features/admin_order/detail_repository.dart';
import 'package:dust_dart/db.dart';

/// Atomically marks one fulfillment shipped and returns the refreshed order.
Future<Result<AdminOrderDetailResponse, AdminCreateShipmentError>>
    createAdminOrderShipment(
  AdminOrderDeps deps,
  String orderId,
  String fulfillmentId,
  String adminId,
  AdminCreateShipment body,
) async {
  if (!body.noNotification) {
    return const Err(AdminCreateShipmentRejected(
      AdminCreateShipmentFailure.notificationUnavailable,
    ));
  }
  if (!_valid(orderId, fulfillmentId, adminId, body)) {
    return const Err(AdminCreateShipmentRejected(
      AdminCreateShipmentFailure.invalid,
    ));
  }
  final labelIds = [for (final _ in body.labels) deps.nextId()];
  final persisted = await deps.serialWrite(
    () => deps.database.transaction<AdminCreateShipmentOutcome>(
      (tx) => _persist(
        AdminCreateShipmentRepository(tx),
        AdminOrderDetailRepository(tx),
        orderId,
        fulfillmentId,
        adminId,
        labelIds,
        body,
      ),
    ),
  );
  return switch (persisted) {
    Ok(value: AdminCreateShipmentReady(:final response)) => Ok(response),
    Ok(value: AdminCreateShipmentDenied(:final failure)) =>
      Err(AdminCreateShipmentRejected(failure)),
    Err(:final error) => Err(AdminCreateShipmentStorage(error)),
  };
}

bool _valid(
  String orderId,
  String fulfillmentId,
  String adminId,
  AdminCreateShipment body,
) {
  if ([orderId, fulfillmentId, adminId]
      .any((value) => value.isEmpty || value.trim() != value)) {
    return false;
  }
  if (body.items.isEmpty || body.items.length > 100) return false;
  if (body.labels.length > 100) return false;
  final ids = <String>{};
  if (!body.items.every((item) =>
      item.id.isNotEmpty &&
      item.id.trim() == item.id &&
      item.quantity > 0 &&
      ids.add(item.id))) {
    return false;
  }
  return body.labels.every((label) =>
      label.trackingNumber.length <= 255 &&
      _safeUrl(label.trackingUrl) &&
      _safeUrl(label.labelUrl));
}

bool _safeUrl(String value) {
  if (value.isEmpty || value == '#') return true;
  if (value.length > 2048 || value.trim() != value) return false;
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) return false;
  final scheme = uri.scheme.toLowerCase();
  return scheme == 'http' || scheme == 'https';
}

Future<Result<AdminCreateShipmentOutcome, SqlxError>> _persist(
  AdminCreateShipmentRepository writes,
  AdminOrderDetailRepository details,
  String orderId,
  String fulfillmentId,
  String adminId,
  List<String> labelIds,
  AdminCreateShipment body,
) async {
  final targetResult = await writes.target(orderId, fulfillmentId);
  if (targetResult case Err(:final error)) return Err(error);
  final target = (targetResult as Ok<AdminShipmentTarget?, SqlxError>).value;
  if (target == null) return const Ok(_unavailable);
  if (!target.requiresShipping ||
      target.canceled ||
      target.shipped ||
      target.delivered) {
    return const Ok(_invalid);
  }

  final storedResult = await writes.items(fulfillmentId);
  if (storedResult case Err(:final error)) return Err(error);
  final stored =
      (storedResult as Ok<List<AdminShipmentStoredItem>, SqlxError>).value;
  if (stored.length != body.items.length) return const Ok(_invalid);
  final submitted = {for (final item in body.items) item.id: item.quantity};
  if (stored.any((item) => submitted[item.id] != item.quantity)) {
    return const Ok(_invalid);
  }

  final existingResult = await writes.labels(fulfillmentId);
  if (existingResult case Err(:final error)) return Err(error);
  final existing = {
    for (final label
        in (existingResult as Ok<List<AdminShipmentStoredLabel>, SqlxError>)
            .value)
      _labelKey(label.trackingNumber, label.trackingUrl, label.labelUrl),
  };

  final updated = await writes.markShipped(orderId, fulfillmentId, adminId);
  if (updated case Err(:final error)) return Err(error);
  if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
    return const Ok(_invalid);
  }
  for (var index = 0; index < body.labels.length; index++) {
    final label = body.labels[index];
    if (!existing.add(
      _labelKey(label.trackingNumber, label.trackingUrl, label.labelUrl),
    )) {
      continue;
    }
    final inserted = await writes.insertLabel(
      labelIds[index],
      fulfillmentId,
      label.trackingNumber,
      label.trackingUrl,
      label.labelUrl,
    );
    if (inserted case Err(:final error)) return Err(error);
    if ((inserted as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
      return Err(SqlxError.decode('Shipment label could not be inserted'));
    }
  }
  final refreshed = await details.find(orderId);
  if (refreshed case Err(:final error)) return Err(error);
  final response =
      (refreshed as Ok<AdminOrderDetailResponse?, SqlxError>).value;
  return response == null
      ? Err(SqlxError.decode('Shipped order could not be read'))
      : Ok(AdminCreateShipmentReady(response));
}

const _unavailable = AdminCreateShipmentDenied(
  AdminCreateShipmentFailure.unavailable,
);
const _invalid = AdminCreateShipmentDenied(AdminCreateShipmentFailure.invalid);

({String number, String tracking, String label}) _labelKey(
  String number,
  String tracking,
  String label,
) =>
    (number: number, tracking: tracking, label: label);
