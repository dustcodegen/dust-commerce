part of 'order_return_view_model.dart';

OrderReturnFailure _classifyReturnFailure(Object error) {
  if (error is DioException) {
    return switch (error.response?.statusCode) {
      401 => OrderReturnFailure.unauthorized,
      404 => OrderReturnFailure.unavailable,
      409 || 422 => OrderReturnFailure.notEligible,
      _ => OrderReturnFailure.retryable,
    };
  }
  return OrderReturnFailure.retryable;
}
