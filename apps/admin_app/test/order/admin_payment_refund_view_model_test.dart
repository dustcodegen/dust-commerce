import 'dart:convert';
import 'dart:io';

import 'package:admin_app/src/core/admin_authorization_interceptor.dart';
import 'package:admin_app/src/core/admin_session_store.dart';
import 'package:admin_app/src/order/admin_order_detail_api.dart';
import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:admin_app/src/order/admin_payment_refund_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

import 'admin_order_detail_fixture.dart';

void main() {
  late HttpServer server;
  late Uri origin;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    origin = Uri.parse('http://${server.address.address}:${server.port}');
    server.listen(_respond);
  });
  tearDown(() => server.close(force: true));

  test('generated refund client uses Dio authorization and typed contracts',
      () async {
    final dio = Dio()
      ..interceptors.add(AdminAuthorizationInterceptor(
        sessions: _MemoryAdminSessionStore(),
        now: () => DateTime.utc(2026, 9, 14),
      ));
    final api = AdminOrderDetailApi(dio, baseUrl: origin.toString());

    final reasons = await api.refundReasons('', 100, 0);
    final payment = await api.refundPayment('pay_detail', _command);

    expect(reasons.refundReasons.single.label, 'Damaged');
    expect(payment.refundedAmount, 725);
    expect(payment.refunds.single.note, const Some('Seal broken'));
  });

  test('refund state reloads server-authoritative order after mutation',
      () async {
    final api = AdminOrderDetailApi(
      Dio()..options.headers['authorization'] = 'Bearer admin-token',
      baseUrl: origin.toString(),
    );
    final detail = AdminOrderDetailViewModel(
      AdminOrderDetailViewModelArgs(api: api),
    );
    await detail.load('ord_detail');

    await detail.loadRefundReasons();
    final saved = await detail.refundPayment(
      'ord_detail',
      'pay_detail',
      _command,
    );

    expect(saved, isTrue);
    expect(detail.state.status, AdminOrderDetailStatus.ready);
    final order = (detail.state.order as Some<AdminOrderDetail>).value;
    expect(order.paymentRefundedAmount, 725);
    expect(order.paymentRefunds.single.amount, 725);
  });

  test('refund failure preserves loaded order and maps safe copy', () async {
    final api = AdminOrderDetailApi(
      Dio()..options.headers['authorization'] = 'Bearer admin-token',
      baseUrl: origin.toString(),
    );
    final detail = AdminOrderDetailViewModel(
      AdminOrderDetailViewModelArgs(api: api),
    );
    await detail.load('ord_detail');

    final saved = await detail.refundPayment(
      'ord_detail',
      'missing',
      _command,
    );

    expect(saved, isFalse);
    expect(detail.state.order, isA<Some<AdminOrderDetail>>());
    expect(detail.state.refund.status, AdminPaymentRefundStatus.failed);
    expect(detail.state.failure, const Some('This payment no longer exists.'));
  });
}

Future<void> _respond(HttpRequest request) async {
  request.response.headers.contentType = ContentType.json;
  expect(request.headers.value('authorization'), 'Bearer admin-token');
  if (request.uri.path == '/admin/refund-reasons') {
    request.response.write(jsonEncode(_reasonsJson));
  } else if (request.uri.path == '/admin/payments/pay_detail/refund') {
    expect(request.method, 'POST');
    expect(
        jsonDecode(await utf8.decoder.bind(request).join()), _command.toJson());
    request.response.write(jsonEncode(_paymentJson));
  } else if (request.uri.path == '/admin/payments/missing/refund') {
    request.response.statusCode = HttpStatus.notFound;
    request.response.write(jsonEncode({'error': 'missing'}));
  } else if (request.uri.path == '/admin/orders/ord_detail') {
    request.response.write(jsonEncode({
      ...adminOrderDetailJson,
      'payment_refunded_amount': 725,
      'payment_refunds': _paymentJson['refunds'],
    }));
  } else {
    request.response.statusCode = HttpStatus.notFound;
  }
  await request.response.close();
}

const _command = AdminRefundPayment(
  amountValue: 725,
  refundReasonIdValue: 'refund_reason_damaged',
  noteValue: 'Seal broken',
);

const _reasonsJson = <String, Object?>{
  'refund_reasons': <Object?>[
    <String, Object?>{
      'id': 'refund_reason_damaged',
      'label': 'Damaged',
      'code': 'damaged',
      'description': null,
    },
  ],
  'count': 1,
  'limit': 100,
  'offset': 0,
};

const _paymentJson = <String, Object?>{
  'id': 'pay_detail',
  'provider_id': 'manual',
  'amount': 5400,
  'refunded_amount': 725,
  'currency_code': 'eur',
  'status': 'captured',
  'captured_at': '2026-09-10T10:02:00.000Z',
  'refunds': <Object?>[
    <String, Object?>{
      'id': 'refund_1',
      'amount': 725,
      'refund_reason': <String, Object?>{
        'id': 'refund_reason_damaged',
        'label': 'Damaged',
        'code': 'damaged',
        'description': null,
      },
      'note': 'Seal broken',
      'created_by': 'admin_1',
      'created_at': '2026-09-14T02:03:04.000Z',
    },
  ],
};

final class _MemoryAdminSessionStore implements AdminSessionStore {
  Option<StoredAdminSession> value = Some(StoredAdminSession(
    token: 'admin-token',
    expiresAt: DateTime.utc(2026, 9, 15),
  ));

  @override
  Future<void> clear() async => value = const None();

  @override
  Future<Option<StoredAdminSession>> read() async => value;

  @override
  Future<void> write(AdminIssuedToken token) async {}
}
