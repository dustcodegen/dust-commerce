import 'dart:convert';

import 'package:test/test.dart';

import 'customer_group_list_test_support.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start();
    await seedCustomerGroupList(harness);
  });
  tearDown(() => harness.stop());

  test('customer-group list requires a proven admin bearer', () async {
    (await harness.client.get('/admin/customer-groups').send())
        .assertUnauthorized();
  });

  test('customer-group list returns the exact Medusa allowlist', () async {
    final request = harness.client.get(
      '/admin/customer-groups?order=-created_at&limit=1&offset=0',
    )..bearer(await harness.adminToken());

    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json, containsPair('count', 3));
    expect(json, containsPair('limit', 1));
    final groups = json['customer_groups']! as List<Object?>;
    final group = groups.single! as Map<String, Object?>;
    expect(group.keys, {
      'id',
      'name',
      'customers',
      'created_at',
      'updated_at',
    });
    expect(group, containsPair('id', 'cusgrp_vip'));
    expect(group, isNot(contains('metadata')));
    final customers = group['customers']! as List<Object?>;
    expect(customers, hasLength(2));
    expect(
      customers.map((value) => (value! as Map<String, Object?>).keys),
      everyElement({'id'}),
    );
  });

  test('group search, date, and order apply before paging', () async {
    final uri = Uri(path: '/admin/customer-groups', queryParameters: {
      'q': 'TAIL',
      'created_at': jsonEncode({r'$gte': '2026-09-10T00:00:00Z'}),
      'order': 'name',
      'limit': '10',
    });
    final request = harness.client.get(uri.toString())
      ..bearer(await harness.adminToken());

    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    final groups = json['customer_groups']! as List<Object?>;
    expect(groups, hasLength(1));
    expect(groups.single, containsPair('id', 'cusgrp_retail'));

    final updatedUri = Uri(path: '/admin/customer-groups', queryParameters: {
      'updated_at': jsonEncode({r'$gte': '2026-09-12T00:00:00Z'}),
      'order': '-updated_at',
    });
    final updatedRequest = harness.client.get(updatedUri.toString())
      ..bearer(await harness.adminToken());
    final updatedResponse = await updatedRequest.send();
    updatedResponse.assertOk();
    final updatedGroups = (updatedResponse.json!
        as Map<String, Object?>)['customer_groups']! as List<Object?>;
    expect(updatedGroups.map((value) => (value! as Map)['id']), [
      'cusgrp_vip',
    ]);
  });

  test('group list rejects filters and order outside its allowlist', () async {
    final token = await harness.adminToken();
    for (final query in ['order=metadata', 'created_at=tomorrow']) {
      final request = harness.client.get('/admin/customer-groups?$query')
        ..bearer(token);
      (await request.send()).assertBadRequest();
    }
  });
}
