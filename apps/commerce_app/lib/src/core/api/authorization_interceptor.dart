import 'package:commerce_app/src/core/storage/auth_session_store.dart';
import 'package:dio/dio.dart';

/// Adds the stored bearer token at Dio level and handles expired sessions.
///
/// Generated API methods remain credential-free: callers cannot accidentally
/// pass, log, or serialize an authorization header as a method argument.
final class AuthorizationInterceptor extends Interceptor {
  /// Creates the interceptor.
  AuthorizationInterceptor({
    required this.sessions,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// Secure session persistence shared with the account view model.
  final AuthSessionStore sessions;

  final DateTime Function() _now;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _authorize(options, handler);
  }

  Future<void> _authorize(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final session = await sessions.read();
      if (session == null) {
        handler.next(options);
        return;
      }
      if (session.isExpiredAt(_now())) {
        await sessions.clear();
        handler.next(options);
        return;
      }
      options.headers['authorization'] = 'Bearer ${session.token}';
      handler.next(options);
    } on Object catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _clearRejectedSession(err, handler);
  }

  Future<void> _clearRejectedSession(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final authorization = error.requestOptions.headers['authorization'];
      if (error.response?.statusCode == 401 &&
          authorization is String &&
          authorization.startsWith('Bearer ')) {
        await sessions.clear();
      }
    } on Object {
      // A storage failure must not strand Dio's response pipeline.
    }
    handler.next(error);
  }
}
