import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('decodes a merchant-only support request with explicit absence', () {
    final page = AdminCustomerServiceList.fromJson({
      'requests': [
        {
          'id': 'csreq_01',
          'customer_id': null,
          'name': 'Ada Lovelace',
          'email': 'ada@example.com',
          'subject': 'Order question',
          'message': 'Where is my order?',
          'order_reference': 'ORDER-42',
          'status': 'open',
          'resolved_at': null,
          'created_at': '2026-09-15T10:00:00.000Z',
          'updated_at': '2026-09-15T10:00:00.000Z',
        },
      ],
      'count': 1,
      'limit': 20,
      'offset': 0,
    });

    final request = page.requests.single;
    expect(request.customerId, const None<String>());
    expect(request.orderReference, const Some('ORDER-42'));
    expect(request.resolvedAt, const None<DateTime>());
    expect(request.status, AdminCustomerServiceStatus.open);
    expect(request.createdAt.isUtc, isTrue);
  });

  test('round trips an explicit status update', () {
    const update = AdminUpdateCustomerService(
      status: AdminCustomerServiceStatus.inProgress,
    );

    expect(update.toJson(), {'status': 'in_progress'});
    expect(AdminUpdateCustomerService.fromJson(update.toJson()), update);
  });

  test('allows only supported inbox orders', () {
    expect(
      AdminCustomerServiceOrder.parse('-created_at'),
      const Some(AdminCustomerServiceOrder.createdAtDesc),
    );
    expect(AdminCustomerServiceOrder.parse('email'), const None());
  });
}
