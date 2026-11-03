import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_api.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_state.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminShippingProfileViewModel profiles;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('shipping_profiles');
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
    profiles = AdminShippingProfileViewModel(
      AdminShippingProfileViewModelArgs(
        api: AdminShippingProfileApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads and searches active shipping profiles', () async {
    await profiles.load();

    expect(profiles.state.status, AdminShippingProfileStatus.ready);
    expect(profiles.state.count, 1);
    expect(profiles.state.shippingProfiles.single.id, 'sp_default');

    await profiles.search('missing');
    expect(profiles.state.count, 0);
    expect(profiles.state.shippingProfiles, isEmpty);
  });

  test('creates and deletes one shipping profile', () async {
    final created = await profiles.create(const AdminCreateShippingProfile(
      name: '  Fragile Goods  ',
      type: '  fragile  ',
    ));

    final profile = switch (created) {
      Some(:final value) => value,
      None() => fail('Expected a created shipping profile'),
    };
    expect(profile.name, 'Fragile Goods');
    expect(profile.type, 'fragile');
    expect(profiles.state.count, 2);

    expect(
      await profiles.delete(profile.id),
      AdminShippingProfileDeleteOutcome.deleted,
    );
    expect(profiles.state.count, 1);
  });

  test('reports duplicate profile names without losing list state', () async {
    await profiles.load();

    final created = await profiles.create(const AdminCreateShippingProfile(
      name: 'Default Shipping Profile',
      type: 'default',
    ));

    expect(created, const None<AdminShippingProfile>());
    expect(profiles.state.count, 1);
    expect(
      profiles.state.failure,
      const Some('Another shipping profile already uses this name.'),
    );
  });

  test('retains profile filters and order across paging state', () async {
    await profiles.filterByName('Default');

    expect(profiles.state.name, 'Default');
    expect(profiles.state.count, 1);
    expect(profiles.state.shippingProfiles.single.id, 'sp_default');

    await profiles.orderBy(AdminShippingProfileOrder.nameDesc);
    expect(profiles.state.order, AdminShippingProfileOrder.nameDesc);

    await profiles.clearFilters();
    expect(profiles.state.name, '');
    expect(profiles.state.type, '');
    expect(profiles.state.createdAt.isEmpty, isTrue);
    expect(profiles.state.updatedAt.isEmpty, isTrue);
  });
}
