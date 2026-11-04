import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('normalizes and validates one Store support request', () {
    final request = CustomerServiceRequestBody.fromJson({
      'name': '  Ada Lovelace  ',
      'email': '  ADA@Example.COM ',
      'subject': '  Order question ',
      'message': '  Where is my order?  ',
      'order_reference': 'ORDER-42',
    });

    expect(request.validate().isValid, isTrue);
    expect(request.name, 'Ada Lovelace');
    expect(request.email, 'ada@example.com');
    expect(request.subject, 'Order question');
    expect(request.message, 'Where is my order?');
    expect(request.orderReference, const Some('ORDER-42'));
  });

  test('rejects blank content and an invalid email', () {
    const request = CustomerServiceRequestBody(
      name: ' ',
      email: 'not-an-email',
      subject: ' ',
      message: ' ',
    );

    expect(request.validate().isValid, isFalse);
    expect(request.orderReference, const None<String>());
  });

  test('round trips a typed Store acknowledgement', () {
    final submission = CustomerServiceSubmission(
      id: 'csreq_01',
      createdAt: DateTime.utc(2026, 9, 15, 10),
    );

    expect(CustomerServiceSubmission.fromJson(submission.toJson()), submission);
    expect(submission.toJson(), {
      'created_at': '2026-09-15T10:00:00.000Z',
      'id': 'csreq_01',
    });
  });
}
