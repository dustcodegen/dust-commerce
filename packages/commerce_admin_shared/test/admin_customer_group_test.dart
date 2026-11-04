import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('customer-group creation normalizes the Medusa input', () {
    final input = AdminCreateCustomerGroup.fromJson({
      'name': '  VIP Customers  ',
      'metadata': {'source': 'admin'},
    });

    expect(input.name, 'VIP Customers');
    expect(
      input.metadata.match(some: (value) => value, none: () => null),
      {'source': 'admin'},
    );
    expect(input.validate().isValid, isTrue);
    expect(input.toJson(), {
      'name': 'VIP Customers',
      'metadata': {'source': 'admin'},
    });
    expect(
      const AdminCreateCustomerGroup(
        name: '   ',
        metadataValue: null,
      ).validate().isValid,
      isFalse,
    );
  });

  test('customer-group creation decodes the Medusa response envelope', () {
    final response = AdminCustomerGroupCreateResponse.fromJson({
      'customer_group': {
        'id': 'cusgrp_vip',
        'name': 'VIP Customers',
        'customers': <Object?>[],
        'created_at': '2026-09-14T01:02:03.000Z',
        'updated_at': '2026-09-14T01:02:03.000Z',
      },
    });

    expect(response.customerGroup.id, 'cusgrp_vip');
    expect(response.customerGroup.customers, isEmpty);
    expect(response.toJson().keys, {'customer_group'});
  });

  test('customer-group edit normalizes its standalone name input', () {
    final input = AdminUpdateCustomerGroup.fromJson({
      'name': '  Preferred Customers  ',
    });

    expect(input.name, 'Preferred Customers');
    expect(input.validate().isValid, isTrue);
    expect(input.toJson(), {'name': 'Preferred Customers'});
    expect(
      const AdminUpdateCustomerGroup(name: '   ').validate().isValid,
      isFalse,
    );
  });

  test('customer-group deletion keeps the Medusa acknowledgement allowlist',
      () {
    final deleted = AdminCustomerGroupDeleted.fromJson({
      'id': 'cusgrp_vip',
      'object': 'customer_group',
      'deleted': true,
    });

    expect(deleted.id, 'cusgrp_vip');
    expect(deleted.object, 'customer_group');
    expect(deleted.deleted, isTrue);
    expect(deleted.toJson(), {
      'id': 'cusgrp_vip',
      'object': 'customer_group',
      'deleted': true,
    });
  });

  test('customer-group page decodes Medusa list fields only', () {
    final page = AdminCustomerGroupList.fromJson({
      'customer_groups': [
        {
          'id': 'cusgrp_vip',
          'name': 'VIP',
          'customers': [
            {'id': 'cus_ada'},
            {'id': 'cus_grace'},
          ],
          'created_at': '2026-09-14T01:02:03.000Z',
          'updated_at': '2026-09-14T02:03:04.000Z',
        },
      ],
      'count': 1,
      'limit': 10,
      'offset': 0,
    });

    final group = page.customerGroups.single;
    expect(group.id, 'cusgrp_vip');
    expect(group.name, 'VIP');
    expect(group.customers.map((customer) => customer.id).toList(), [
      'cus_ada',
      'cus_grace',
    ]);
    expect(group.createdAt.isUtc, isTrue);
    expect(group.updatedAt.isUtc, isTrue);
    expect(group.toJson().keys, {
      'id',
      'name',
      'customers',
      'created_at',
      'updated_at',
    });
  });

  test('customer-group detail decodes metadata without inheriting list data',
      () {
    final response = AdminCustomerGroupDetailResponse.fromJson({
      'customer_group': {
        'id': 'cusgrp_vip',
        'name': 'VIP Customers',
        'customers': [
          {'id': 'cus_ada'},
        ],
        'metadata': {
          'source': 'admin',
          'priority': 1,
        },
        'created_at': '2026-09-14T01:02:03.000Z',
        'updated_at': '2026-09-14T02:03:04.000Z',
      },
    });

    final group = response.customerGroup;
    expect(group.id, 'cusgrp_vip');
    expect(group.customers.single.id, 'cus_ada');
    expect(
      group.metadata.match(some: (value) => value, none: () => null),
      {'source': 'admin', 'priority': 1},
    );
    expect(group.createdAt.isUtc, isTrue);
    expect(response.toJson().keys, {'customer_group'});
    expect(group.toJson().keys, {
      'id',
      'name',
      'customers',
      'metadata',
      'created_at',
      'updated_at',
    });
  });

  test('customer-group ordering accepts only visible table fields', () {
    expect(
      AdminCustomerGroupOrder.parse('-updated_at'),
      const Some(AdminCustomerGroupOrder.updatedAtDesc),
    );
    expect(AdminCustomerGroupOrder.parse('metadata'), const None());
  });
}
