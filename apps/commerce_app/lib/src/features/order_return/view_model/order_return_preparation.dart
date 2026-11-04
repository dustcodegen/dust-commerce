part of 'order_return_view_model.dart';

OrderReturnRequestState _preparedReturnState(Order order) {
  if (!order.isPaid ||
      !order.items.any((item) => item.detail.deliveredQuantity > 0)) {
    return const OrderReturnRequestState(
      status: OrderReturnRequestStatus.failed,
      failure: Some(OrderReturnFailure.notEligible),
    );
  }
  return OrderReturnRequestState(
    status: OrderReturnRequestStatus.ready,
    orderId: Some(order.id),
    availableQuantities: {
      for (final item in order.items)
        if (item.detail.returnableQuantity > 0)
          item.id: item.detail.returnableQuantity,
    },
  );
}
