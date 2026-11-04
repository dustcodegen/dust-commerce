import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('refund command keeps optional fields explicit', () {
    const command = AdminRefundPayment(
      amountValue: 725,
      refundReasonIdValue: 'ref_damaged',
      noteValue: 'Seal broken',
    );

    expect(command.amount, const Some(725));
    expect(command.refundReasonId, const Some('ref_damaged'));
    expect(command.note, const Some('Seal broken'));
    expect(command.toJson(), {
      'amount': 725,
      'refund_reason_id': 'ref_damaged',
      'note': 'Seal broken',
    });
  });

  test('refunded payment decodes audit history and DateTime', () {
    final payment = AdminRefundedPayment.fromJson({
      'id': 'pay_1',
      'provider_id': 'manual',
      'amount': 2200,
      'refunded_amount': 725,
      'currency_code': 'usd',
      'status': 'captured',
      'captured_at': '2026-09-14T01:02:03.000Z',
      'refunds': [
        {
          'id': 'refund_1',
          'amount': 725,
          'refund_reason': {
            'id': 'ref_damaged',
            'label': 'Damaged',
            'code': 'damaged',
            'description': null,
          },
          'note': 'Seal broken',
          'created_by': 'admin_1',
          'created_at': '2026-09-14T02:03:04.000Z',
        },
      ],
    });

    expect(payment.refundableAmount, 1475);
    expect(payment.refunds.single.note, const Some('Seal broken'));
    expect(payment.refunds.single.refundReason, isA<Some<AdminRefundReason>>());
    expect(payment.capturedAt.isUtc, isTrue);
  });

  test('refund reason list preserves paging metadata', () {
    final page = AdminRefundReasonList.fromJson({
      'refund_reasons': [
        {
          'id': 'ref_other',
          'label': 'Other',
          'code': 'other',
          'description': 'Explain in the note',
        },
      ],
      'count': 1,
      'limit': 20,
      'offset': 0,
    });

    expect(page.refundReasons.single.description,
        const Some('Explain in the note'));
  });
}
