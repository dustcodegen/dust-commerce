import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/promotion/admin_promotion_api.dart';
import 'package:admin_app/src/promotion/admin_promotion_create_view_model.dart';
import 'package:admin_app/src/promotion/admin_promotion_create_state.dart';
import 'package:admin_app/src/promotion/admin_promotion_state.dart';
import 'package:admin_app/src/promotion/admin_promotion_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminPromotionApi api;
  late AdminPromotionViewModel promotions;
  late AdminPromotionCreateViewModel create;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_promotions');
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
    api = AdminPromotionApi(dio, baseUrl: server.origin);
    promotions = AdminPromotionViewModel(
      AdminPromotionViewModelArgs(
        api: api,
      ),
    );
    create = AdminPromotionCreateViewModel(
      AdminPromotionCreateViewModelArgs(api: api),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads and searches promotions', () async {
    await promotions.load();

    expect(promotions.state.status, AdminPromotionLoadStatus.ready);
    expect(promotions.state.count, 1);
    expect(promotions.state.promotions.single.code, 'WELCOME10');

    await promotions.search('missing');
    expect(promotions.state.count, 0);
    expect(promotions.state.promotions, isEmpty);
  });

  test('reads promotion detail through the generated client', () async {
    final detail = await api.promotion('promo_welcome');

    expect(detail.promotion.code, 'WELCOME10');
    expect(detail.promotion.status, AdminPromotionStatus.active);
  });

  test('retains date filters and order across loads', () async {
    final range = AdminDateFilter(
      greaterThanOrEqual: Some(DateTime.utc(2000)),
      lessThanOrEqual: Some(DateTime.utc(2100)),
    );

    await promotions.filterByCreatedAt(range);
    expect(promotions.state.createdAt, range);
    expect(promotions.state.count, 1);

    await promotions.orderBy(AdminPromotionOrder.createdAtAsc);
    expect(promotions.state.order, AdminPromotionOrder.createdAtAsc);

    await promotions.clearFilters();
    expect(promotions.state.createdAt.isEmpty, isTrue);
    expect(promotions.state.updatedAt.isEmpty, isTrue);
  });

  test('creates a promotion through the generated Admin client', () async {
    final created = await create.create(
      const AdminCreatePromotion(
        code: '  local_10 ',
        type: 'percentage',
        value: 1000,
        currencyCodeValue: null,
        startsAtValue: null,
        endsAtValue: null,
        usageLimitValue: 10,
      ),
    );

    expect(created, isA<Some<AdminPromotion>>());
    expect(create.state.status, AdminPromotionCreateStatus.idle);
    expect((created as Some<AdminPromotion>).value.code, 'LOCAL_10');
  });
}
