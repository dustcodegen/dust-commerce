part of 'account_view_model.dart';

String _accountMessageOf(Object error, AccountOperation operation) {
  if (error is DioException) {
    if (operation == AccountOperation.changePassword &&
        error.response?.statusCode == 422) {
      return _firstFieldError(error) ?? 'Current password is incorrect.';
    }
    return switch (error.response?.statusCode) {
      401 => operation == AccountOperation.changePassword
          ? 'Your session has expired. Please sign in again.'
          : 'The email or password is incorrect.',
      409 => 'An account already exists for this email.',
      422 => 'Check the information you entered and try again.',
      429 => 'Too many sign-in requests. Please try again shortly.',
      _
          when error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout =>
        'You appear to be offline. Check your connection and try again.',
      _ => operation == AccountOperation.restore
          ? 'We could not verify your saved session. Please try again.'
          : 'We could not complete that account request. Please try again.',
    };
  }
  return 'We could not complete that account request. Please try again.';
}

String? _firstFieldError(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, Object?>) return null;
  final fields = data['fields'];
  if (fields is! Map<String, Object?>) return null;
  for (final messages in fields.values) {
    if (messages is List<Object?> &&
        messages.isNotEmpty &&
        messages.first is String) {
      return messages.first as String;
    }
  }
  return null;
}
