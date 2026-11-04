import 'package:admin_app/src/core/admin_session_store.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';

/// Attaches only the isolated admin bearer at Dio level.
final class AdminAuthorizationInterceptor extends Interceptor {
  /// Creates the interceptor.
  AdminAuthorizationInterceptor({
    required this.sessions,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// Admin-only secure session persistence.
  final AdminSessionStore sessions;
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
      switch (await sessions.read()) {
        case Some(value: final session) when !session.isExpiredAt(_now()):
          options.headers['authorization'] = 'Bearer ${session.token}';
        case Some():
          await sessions.clear();
        case None():
          break;
      }
      handler.next(options);
    } on Object catch (error, stackTrace) {
      handler.reject(DioException(
        requestOptions: options,
        error: error,
        stackTrace: stackTrace,
      ));
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
      final header = error.requestOptions.headers['authorization'];
      if (error.response?.statusCode == 401 &&
          header is String &&
          header.startsWith('Bearer ')) {
        await sessions.clear();
      }
    } on Object {
      // Storage failure must not strand Dio's response pipeline.
    }
    handler.next(error);
  }
}
