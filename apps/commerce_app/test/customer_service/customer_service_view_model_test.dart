import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('submits the input and retains only its acknowledgement', () async {
    CustomerServiceRequestBody? sent;
    final model = CustomerServiceViewModel(CustomerServiceViewModelArgs(
      api: _SupportApi((input) async {
        sent = input;
        return _submission;
      }),
    ));

    await model.submit(_input);

    expect(sent, _input);
    expect(model.state.status, CustomerServiceStatus.succeeded);
    expect(model.state.submission, Some(_submission));
    expect(model.state.toString(), isNot(contains(_input.message)));
    model.dispose();
  });

  test('rejects invalid input before calling the Store API', () async {
    var calls = 0;
    final model = CustomerServiceViewModel(CustomerServiceViewModelArgs(
      api: _SupportApi((_) async {
        calls++;
        return _submission;
      }),
    ));

    await model.submit(const CustomerServiceRequestBody(
      name: '',
      email: 'not-an-email',
      subject: '',
      message: '',
    ));

    expect(calls, 0);
    expect(model.state.status, CustomerServiceStatus.failed);
    expect(
      model.state.failure,
      const Some(CustomerServiceFailure.invalidInput),
    );
    model.dispose();
  });

  for (final entry in {
    401: CustomerServiceFailure.sessionExpired,
    422: CustomerServiceFailure.invalidInput,
    500: CustomerServiceFailure.retryable,
  }.entries) {
    test('classifies ${entry.key} without exposing transport state', () async {
      final request = RequestOptions(path: '/store/customer-service');
      final model = CustomerServiceViewModel(CustomerServiceViewModelArgs(
        api: _SupportApi((_) => Future.error(DioException(
              requestOptions: request,
              response: Response<void>(
                requestOptions: request,
                statusCode: entry.key,
              ),
            ))),
      ));

      await model.submit(_input);

      expect(model.state.status, CustomerServiceStatus.failed);
      expect(model.state.failure, Some(entry.value));
      model.dispose();
    });
  }

  test('reset ignores an in-flight response from the prior form', () async {
    final deferred = Completer<CustomerServiceSubmission>();
    final model = CustomerServiceViewModel(CustomerServiceViewModelArgs(
      api: _SupportApi((_) => deferred.future),
    ));

    final pending = model.submit(_input);
    model.reset();
    deferred.complete(_submission);
    await pending;

    expect(model.state, const CustomerServiceState());
    model.dispose();
  });
}

final class _SupportApi implements CommerceApi {
  const _SupportApi(this.call);

  final Future<CustomerServiceSubmission> Function(
    CustomerServiceRequestBody input,
  ) call;

  @override
  Future<CustomerServiceSubmission> submitCustomerService(
    CustomerServiceRequestBody body,
  ) =>
      call(body);

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unused API method');
}

const _input = CustomerServiceRequestBody(
  name: 'Ada Lovelace',
  email: 'ada@example.com',
  subject: 'Order question',
  message: 'Can you help with order 42?',
  orderReferenceValue: '42',
);

final _submission = CustomerServiceSubmission(
  id: 'csr_01',
  createdAt: DateTime.utc(2026, 9, 15, 10),
);
