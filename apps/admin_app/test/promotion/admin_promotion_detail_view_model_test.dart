import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/promotion/admin_promotion_api.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_state.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminPromotionDetailViewModel detail;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('promotion_detail');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    await bootstrapAdmin(
      database,
      const AdminCredentials(
        email: 'owner@example.com',
        password: 'correct horse battery staple',
      ),
      nextId: () => 'admin_owner',
      passwordWork: PasswordWorkLimiter(),
    );
    server = await TestClient.serve(buildApp(database));
    final token = await AdminApi(Dio(), baseUrl: server.origin).signIn(
      const AdminCredentials(
        email: 'owner@example.com',
        password: 'correct horse battery staple',
      ),
    );
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    detail = AdminPromotionDetailViewModel(
      AdminPromotionDetailViewModelArgs(
        api: AdminPromotionApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads one allowlisted promotion', () async {
    await detail.load('promo_welcome');

    expect(detail.state.status, AdminPromotionDetailStatus.ready);
    final promotion = switch (detail.state.promotion) {
      Some(:final value) => value,
      None() => fail('Expected one promotion'),
    };
    expect(promotion.code, 'WELCOME10');
    expect(promotion.status, AdminPromotionStatus.active);
  });

  test('uses Option state for an unknown promotion', () async {
    await detail.load('promo_missing');

    expect(detail.state.status, AdminPromotionDetailStatus.failed);
    expect(detail.state.promotion, const None<AdminPromotion>());
    expect(
        detail.state.failure, const Some('This promotion no longer exists.'));
  });
}
