import 'package:commerce_server/src/features/order_return/deps.dart';
import 'package:commerce_server/src/features/order_return/failure.dart';
import 'package:commerce_server/src/features/order_return/model.dart';
import 'package:commerce_server/src/features/order_return/outcome.dart';
import 'package:commerce_server/src/features/order_return/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Atomically validates and records one customer return request.
Future<Result<OrderReturnResponse, OrderReturnError>> createOrderReturn(
  OrderReturnDeps deps,
  String customerId,
  OrderReturnRequestBody body,
) async {
  final returnId = deps.clock.nextId();
  final itemIds = [for (final _ in body.items) deps.clock.nextId()];
  final persisted = await deps.serialWrite(
    () => deps.database.transaction<OrderReturnOutcome>(
      (tx) => _persist(
        OrderReturnReadRepository(tx),
        OrderReturnCreateRepository(tx),
        customerId,
        body,
        returnId,
        itemIds,
      ),
    ),
  );

  return switch (persisted) {
    Ok(value: OrderReturnReady(:final response)) => Ok(response),
    Ok(value: OrderReturnDenied(:final failure)) =>
      Err(OrderReturnRejected(failure)),
    Err(:final error) => Err(OrderReturnStorage(error)),
  };
}

Future<Result<OrderReturnOutcome, SqlxError>> _persist(
  OrderReturnReadRepository reads,
  OrderReturnCreateRepository creates,
  String customerId,
  OrderReturnRequestBody body,
  String returnId,
  List<String> itemIds,
) async {
  final foundOrder = await reads.order(body.orderId, customerId);
  if (foundOrder case Err(:final error)) return Err(error);
  final order = optionOf(
    (foundOrder as Ok<OrderReturnCandidate?, SqlxError>).value,
  );
  if (order case None()) {
    return const Ok(OrderReturnDenied(OrderReturnFailure.noOrder));
  }
  final candidate = (order as Some<OrderReturnCandidate>).value;
  if (candidate.paymentStatus != 'captured') {
    return const Ok(OrderReturnDenied(OrderReturnFailure.ineligibleOrder));
  }

  final seen = <String>{};
  for (final item in body.items) {
    if (!seen.add(item.itemId)) {
      return const Ok(OrderReturnDenied(OrderReturnFailure.invalidItem));
    }
    final valid = await _validateItem(reads, body.orderId, item);
    if (valid case Err(:final error)) return Err(error);
    if ((valid as Ok<Option<OrderReturnFailure>, SqlxError>).value
        case Some(value: final failure)) {
      return Ok(OrderReturnDenied(failure));
    }
  }

  final inserted = await creates.request(
    returnId,
    body.orderId,
    customerId,
    _optional(body.note),
  );
  if (inserted case Err(:final error)) return Err(error);
  for (var index = 0; index < body.items.length; index++) {
    final item = body.items[index];
    final insertedItem = await creates.item(
      itemIds[index],
      returnId,
      item.itemId,
      item.quantity,
      _optional(item.reasonId),
      _optional(item.note),
    );
    if (insertedItem case Err(:final error)) return Err(error);
  }

  final response = await reads.response(returnId);
  if (response case Err(:final error)) return Err(error);
  return switch (optionOf(
    (response as Ok<OrderReturnResponse?, SqlxError>).value,
  )) {
    Some(:final value) => Ok(OrderReturnReady(value)),
    None() => Err(SqlxError.decode('Created return could not be read')),
  };
}

Future<Result<Option<OrderReturnFailure>, SqlxError>> _validateItem(
  OrderReturnReadRepository reads,
  String orderId,
  OrderReturnItemInput input,
) async {
  final found = await reads.item(orderId, input.itemId);
  if (found case Err(:final error)) return Err(error);
  final item = optionOf(
    (found as Ok<OrderReturnItemCandidate?, SqlxError>).value,
  );
  if (item case None()) {
    return const Ok(Some(OrderReturnFailure.invalidItem));
  }
  final candidate = (item as Some<OrderReturnItemCandidate>).value;
  if (candidate.claimedQuantity + input.quantity >
      candidate.deliveredQuantity) {
    return const Ok(Some(OrderReturnFailure.quantityUnavailable));
  }
  if (input.reasonId case Some(value: final reasonId)) {
    final reason = await reads.reason(reasonId);
    if (reason case Err(:final error)) return Err(error);
    if ((reason as Ok<String?, SqlxError>).value == null) {
      return const Ok(Some(OrderReturnFailure.invalidReason));
    }
  }
  return const Ok(None<OrderReturnFailure>());
}

String? _optional(Option<String> value) => switch (value) {
      Some(value: final text) when text.trim().isNotEmpty => text.trim(),
      Some() || None() => null,
    };
