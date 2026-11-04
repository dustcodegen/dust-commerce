part of 'checkout_view_model.dart';

String _checkoutMessageOf(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['error'] is String) {
      return data['error']! as String;
    }
  }
  return 'Could not complete your order. Your details are still here.';
}
