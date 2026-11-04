import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:test/test.dart';

void main() {
  test('customer-group membership batch matches Medusa add/remove JSON', () {
    final input = AdminBatchCustomerGroupCustomers.fromJson({
      'add': ['cus_ada', 'cus_grace'],
      'remove': ['cus_guest'],
    });

    expect(input.add, ['cus_ada', 'cus_grace']);
    expect(input.remove, ['cus_guest']);
    expect(input.validate().isValid, isTrue);
    expect(input.toJson(), {
      'add': ['cus_ada', 'cus_grace'],
      'remove': ['cus_guest'],
    });
  });

  test('customer-group membership batch defaults omitted sides to empty', () {
    final input = AdminBatchCustomerGroupCustomers.fromJson({
      'add': ['cus_ada'],
    });

    expect(input.add, ['cus_ada']);
    expect(input.remove, isEmpty);
    expect(input.toJson(), {
      'add': ['cus_ada'],
      'remove': <String>[],
    });
  });
}
