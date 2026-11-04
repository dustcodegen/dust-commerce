import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_api.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_detail_state.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminShippingProfileDetailViewModel detail;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('shipping_profile');
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
    detail = AdminShippingProfileDetailViewModel(
      AdminShippingProfileDetailViewModelArgs(
        api: AdminShippingProfileApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads one allowlisted shipping profile', () async {
    await detail.load('sp_default');

    expect(detail.state.status, AdminShippingProfileDetailStatus.ready);
    final profile = switch (detail.state.shippingProfile) {
      Some(:final value) => value,
      None() => fail('Expected one shipping profile'),
    };
    expect(profile.name, 'Default Shipping Profile');
    expect(profile.type, 'default');
  });

  test('uses Option state for an unknown profile', () async {
    await detail.load('sp_missing');

    expect(detail.state.status, AdminShippingProfileDetailStatus.failed);
    expect(detail.state.shippingProfile, const None<AdminShippingProfile>());
    expect(
      detail.state.failure,
      const Some('This shipping profile no longer exists.'),
    );
  });
}
