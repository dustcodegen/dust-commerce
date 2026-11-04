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

  test('customer list requires a proven admin bearer', () async {
    (await harness.client.get('/admin/customers').send()).assertUnauthorized();
  });

  test('customer list accepts generated-client empty optional filters',
      () async {
    final request = harness.client.get(
      '/admin/customers?q=&has_account=&created_at=&updated_at='
      '&order=-created_at&limit=20&offset=0',
    )..bearer(await harness.adminToken());

    final response = await request.send();

    response.assertOk();
    expect(response.json, containsPair('count', 3));
  });

  test('customer list exposes a bounded newest-first allowlist', () async {
    final request = harness.client.get('/admin/customers?limit=1&offset=0')
      ..bearer(await harness.adminToken());
    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json, containsPair('count', 3));
    expect(json, containsPair('limit', 1));
    final customers = json['customers']! as List<Object?>;
    final customer = customers.single! as Map<String, Object?>;
    expect(customer.keys, {
      'created_at',
      'email',
      'first_name',
      'has_account',
      'id',
      'last_name',
      'updated_at',
    });
    expect(customer, containsPair('id', 'cus_guest'));
    expect(customer, isNot(contains('metadata')));
  });

  test('customer list searches, filters, orders, and dates before paging',
      () async {
    final uri = Uri(path: '/admin/customers', queryParameters: {
      'q': 'ADA',
      'has_account': 'true',
      'created_at': jsonEncode({r'$gte': '2026-09-10T00:00:00Z'}),
      'order': 'email',
      'limit': '20',
    });
    final request = harness.client.get(uri.toString())
      ..bearer(await harness.adminToken());
    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    final customers = json['customers']! as List<Object?>;
    expect(customers, hasLength(1));
    expect(customers.single, containsPair('id', 'cus_ada'));
    expect(customers.single, containsPair('has_account', true));
  });

  test('customer list scopes active group members before count and paging',
      () async {
    final request = harness.client.get(
      '/admin/customers?groups=cusgrp_vip&order=email&limit=1&offset=0',
    )..bearer(await harness.adminToken());

    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json, containsPair('count', 2));
    expect(json['customers'], [containsPair('id', 'cus_ada')]);

    for (final groupId in ['cusgrp_retired', 'cusgrp_missing']) {
      final empty = harness.client.get('/admin/customers?groups=$groupId')
        ..bearer(await harness.adminToken());
      final emptyJson = (await empty.send()).json! as Map<String, Object?>;
      expect(emptyJson, containsPair('count', 0));
    }
  });

  test('customer list rejects filters and order keys outside its allowlist',
      () async {
    final token = await harness.adminToken();
    for (final query in [
      'has_account=yes',
      'order=metadata',
      'created_at=tomorrow',
    ]) {
      final request = harness.client.get('/admin/customers?$query')
        ..bearer(token);
      (await request.send()).assertBadRequest();
    }
  });
}
