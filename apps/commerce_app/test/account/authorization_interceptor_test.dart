import 'package:commerce_app/commerce_app.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/support.dart';

void main() {
  final now = DateTime.utc(2026, 9, 5, 12);

  test('adds an unexpired bearer without API method parameters', () async {
    final sessions = MemoryAuthSessionStore()
      ..value = StoredAuthSession(
        token: 'private-token',
        expiresAt: now.add(const Duration(hours: 1)),
      );
    final adapter = _RecordingAdapter();
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthorizationInterceptor(sessions: sessions, now: () => now),
      );

    await dio.get<void>('https://example.invalid/store/customers/me');

    expect(adapter.authorization, 'Bearer private-token');
  });

  test('does not attach and clears an expired bearer', () async {
    final sessions = MemoryAuthSessionStore()
      ..value = StoredAuthSession(
        token: 'expired-token',
        expiresAt: now,
      );
    final adapter = _RecordingAdapter();
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthorizationInterceptor(sessions: sessions, now: () => now),
      );

    await dio.get<void>('https://example.invalid/store/customers/me');

    expect(adapter.authorization, isNull);
    expect(sessions.value, isNull);
  });
}

final class _RecordingAdapter implements HttpClientAdapter {
  String? authorization;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorization = options.headers['authorization'] as String?;
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}
