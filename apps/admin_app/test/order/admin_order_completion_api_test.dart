import 'dart:convert';
import 'dart:io';

import 'package:admin_app/src/core/admin_authorization_interceptor.dart';
import 'package:admin_app/src/core/admin_session_store.dart';
import 'package:admin_app/src/order/admin_order_detail_api.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

import 'admin_order_detail_fixture.dart';

void main() {
  test('generated client posts completion through Dio authorization', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final sessions = _MemoryAdminSessionStore();
    final dio = Dio()
      ..interceptors.add(AdminAuthorizationInterceptor(
        sessions: sessions,
        now: () => DateTime.utc(2026, 9, 14),
      ));
    final api = AdminOrderDetailApi(
      dio,
      baseUrl: 'http://${server.address.address}:${server.port}',
    );
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      expect(request.method, 'POST');
      expect(request.uri.path, '/admin/orders/ord_detail/complete');
      expect(request.headers.value('authorization'), 'Bearer admin-token');
      expect(await utf8.decoder.bind(request).join(), isEmpty);
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        ...adminOrderDetailJson,
        'status': 'completed',
      }));
      await request.response.close();
    });

    final order = await api.completeOrder('ord_detail');

    expect(order.status, AdminOrderStatus.completed);
    expect(order.paymentStatus, AdminOrderPaymentStatus.captured);
  });
}

final class _MemoryAdminSessionStore implements AdminSessionStore {
  Option<StoredAdminSession> value = Some(StoredAdminSession(
    token: 'admin-token',
    expiresAt: DateTime.utc(2026, 9, 15),
  ));

  @override
  Future<void> clear() async => value = const None();

  @override
  Future<Option<StoredAdminSession>> read() async => value;

  @override
  Future<void> write(AdminIssuedToken token) async {}
}
