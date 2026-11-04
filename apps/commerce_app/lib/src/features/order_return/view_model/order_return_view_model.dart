import 'dart:async';

import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/order_return/model/model.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'order_return_view_model.g.dart';
part 'order_return_failure.dart';
part 'order_return_preparation.dart';
part 'order_return_reasons.dart';

/// Dependencies for the authenticated customer return form.
final class OrderReturnViewModelArgs extends ViewModelArgs {
  /// Creates return-request dependencies.
  const OrderReturnViewModelArgs({
    required this.api,
    this.onCreated = _ignoreCreatedReturn,
    super.observer,
  });

  /// Generated Store API with authorization attached by Dio.
  final CommerceApi api;

  /// Publishes one authoritative acknowledgement to sibling return state.
  final void Function(OrderReturnView) onCreated;
}

/// Owns item selection and one authenticated return-request operation.
@ViewModel(state: OrderReturnRequestState, args: OrderReturnViewModelArgs)
final class OrderReturnViewModel extends $OrderReturnViewModel {
  /// Creates the return-request state machine.
  OrderReturnViewModel(super.args);

  var _generation = 0;

  /// Starts a fresh form from the order's current returnable quantities.
  void prepare(Order order) {
    _generation++;
    emit(_preparedReturnState(order));
  }

  /// Clears form state and ignores a previous in-flight request.
  void reset() {
    _generation++;
    emit(const OrderReturnRequestState());
  }

  /// Expands the form only after an eligible order has been prepared.
  void open() {
    if (state.orderId case Some()) {
      emit(state.copyWith(expanded: true));
      if (state.reasonStatus
          case OrderReturnReasonStatus.idle || OrderReturnReasonStatus.failed) {
        unawaited(loadReasons());
      }
    }
  }

  /// Returns to the compact help link without losing submitted server state.
  void close() {
    if (state.status == OrderReturnRequestStatus.submitting) return;
    emit(state.copyWith(expanded: false));
  }

  /// Selects an item at quantity one, or removes an existing selection.
  void toggle(String itemId) {
    if (state.status == OrderReturnRequestStatus.submitting ||
        !state.availableQuantities.containsKey(itemId)) {
      return;
    }
    final quantities = {...state.quantities};
    final reasons = {...state.reasonIds};
    if (quantities.containsKey(itemId)) {
      quantities.remove(itemId);
      reasons.remove(itemId);
    } else {
      quantities[itemId] = 1;
    }
    _edit(quantities: quantities, reasonIds: reasons);
  }

  /// Replaces the quantity of an already-selected item when valid.
  void setQuantity(String itemId, int quantity) {
    final maximum = state.availableQuantities[itemId];
    if (state.status == OrderReturnRequestStatus.submitting ||
        maximum == null ||
        !state.quantities.containsKey(itemId) ||
        quantity < 1 ||
        quantity > maximum) {
      return;
    }
    _edit(quantities: {...state.quantities, itemId: quantity});
  }

  /// Retains normalized optional context without nullable UI state.
  void setNote(String value) {
    if (state.status == OrderReturnRequestStatus.submitting) return;
    final normalized = value.trim();
    _edit(note: normalized.isEmpty ? const None() : Some(normalized));
  }

  /// Submits the current selection to the generated Store client.
  Future<void> submit() async {
    if (state.status == OrderReturnRequestStatus.submitting) return;
    final orderId = switch (state.orderId) {
      Some(value: final id) => id,
      None() => null,
    };
    if (orderId == null || state.quantities.isEmpty) {
      emit(state.copyWith(
        status: OrderReturnRequestStatus.failed,
        failure: const Some(OrderReturnFailure.invalidSelection),
      ));
      return;
    }
    final generation = _generation;
    emit(state.copyWith(
      status: OrderReturnRequestStatus.submitting,
      failure: const None(),
    ));
    try {
      final response = await args.api.requestOrderReturn(
        OrderReturnRequestBody(
          orderId: orderId,
          items: [
            for (final entry in state.quantities.entries)
              OrderReturnItemInput(
                itemId: entry.key,
                quantity: entry.value,
                reasonIdValue: state.reasonIds[entry.key],
              ),
          ],
          noteValue: state.note.match(some: (value) => value, none: () => null),
        ),
      );
      if (generation != _generation) return;
      if (response.orderId != orderId ||
          response.itemQuantity != state.itemQuantity) {
        throw StateError('Unexpected return acknowledgement');
      }
      emit(state.copyWith(
        status: OrderReturnRequestStatus.succeeded,
        request: Some(response),
      ));
      args.onCreated(response);
    } on Object catch (error) {
      if (generation != _generation) return;
      emit(state.copyWith(
        status: OrderReturnRequestStatus.failed,
        failure: Some(_classifyReturnFailure(error)),
      ));
    }
  }

  void _edit({
    Map<String, int>? quantities,
    Map<String, String>? reasonIds,
    Option<String>? note,
  }) =>
      emit(state.copyWith(
        status: OrderReturnRequestStatus.ready,
        quantities: quantities ?? state.quantities,
        reasonIds: reasonIds ?? state.reasonIds,
        note: note ?? state.note,
        request: const None(),
        failure: const None(),
      ));

  void _set(OrderReturnRequestState next) => emit(next);
}

void _ignoreCreatedReturn(OrderReturnView _) {}
