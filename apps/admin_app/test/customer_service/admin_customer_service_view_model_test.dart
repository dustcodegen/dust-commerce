import 'dart:async';

import 'package:admin_app/src/customer_service/admin_customer_service_api.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_state.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads with normalized filters and allowlisted ordering', () async {
    final api = _CustomerServiceApi()..listed = _page([_request]);
    final model = _model(api);

    await model.load(
      query: '  damaged  ',
      statuses: const [AdminCustomerServiceStatus.inProgress],
      order: AdminCustomerServiceOrder.updatedAtDesc,
    );

    expect(api.listArguments, [
      'damaged',
      'in_progress',
      '-updated_at',
      20,
      0,
    ]);
    expect(model.state.status, AdminCustomerServiceListStatus.ready);
    expect(model.state.requests, [_request]);
    model.dispose();
  });

  test('replaces a visible request after one flat status update', () async {
    final updated = _copy(status: AdminCustomerServiceStatus.inProgress);
    final api = _CustomerServiceApi()
      ..listed = _page([_request])
      ..updated = updated;
    final model = _model(api);
    await model.load();

    final saved = await model.updateStatus(
      _request.id,
      AdminCustomerServiceStatus.inProgress,
    );

    expect(saved, isTrue);
    expect(api.updatedBody?.status, AdminCustomerServiceStatus.inProgress);
    expect(model.state.requests.single, updated);
    expect(model.state.updatingId, const None<String>());
    model.dispose();
  });

  test('removes a request that no longer matches its active filter', () async {
    final api = _CustomerServiceApi()
      ..listed = _page([_request])
      ..updated = _copy(status: AdminCustomerServiceStatus.resolved);
    final model = _model(api);
    await model.filter(const [AdminCustomerServiceStatus.open]);

    await model.updateStatus(_request.id, AdminCustomerServiceStatus.resolved);

    expect(model.state.requests, isEmpty);
    expect(model.state.count, 0);
    model.dispose();
  });

  test('reports an expired session without exposing transport state', () async {
    final request = RequestOptions(path: '/admin/customer-service');
    final api = _CustomerServiceApi()
      ..listError = DioException(
        requestOptions: request,
        response: Response<void>(requestOptions: request, statusCode: 401),
      );
    final model = _model(api);

    await model.load();

    expect(model.state.status, AdminCustomerServiceListStatus.failed);
    expect(
      model.state.failure,
      const Some('Your admin session has expired.'),
    );
    model.dispose();
  });

  test('ignores a stale list response after a newer search', () async {
    final first = Completer<AdminCustomerServiceList>();
    final api = _CustomerServiceApi()..responses.add(first.future);
    api.responses.add(Future.value(_page([_request])));
    final model = _model(api);

    final stale = model.search('old');
    await model.search('new');
    first.complete(_page([_copy(subject: 'Stale')]));
    await stale;

    expect(model.state.query, 'new');
    expect(model.state.requests.single.subject, 'Damaged cup');
    model.dispose();
  });
}

AdminCustomerServiceViewModel _model(_CustomerServiceApi api) =>
    AdminCustomerServiceViewModel(AdminCustomerServiceViewModelArgs(api: api));

final class _CustomerServiceApi implements AdminCustomerServiceApi {
  AdminCustomerServiceList listed = _page(const []);
  AdminCustomerServiceRequest updated = _request;
  Object? listError;
  final responses = <Future<AdminCustomerServiceList>>[];
  List<Object?>? listArguments;
  AdminUpdateCustomerService? updatedBody;

  @override
  Future<AdminCustomerServiceList> list(
    String query,
    String statuses,
    String order,
    int limit,
    int offset,
  ) {
    listArguments = [query, statuses, order, limit, offset];
    if (listError case final Object error) return Future.error(error);
    if (responses.isNotEmpty) return responses.removeAt(0);
    return Future.value(listed);
  }

  @override
  Future<AdminCustomerServiceRequest> update(
    String id,
    AdminUpdateCustomerService body,
  ) async {
    updatedBody = body;
    return updated;
  }
}

AdminCustomerServiceList _page(List<AdminCustomerServiceRequest> requests) =>
    AdminCustomerServiceList(
      requests: requests,
      count: requests.length,
      limit: 20,
      offset: 0,
    );

final AdminCustomerServiceRequest _request = _copy();

AdminCustomerServiceRequest _copy({
  String subject = 'Damaged cup',
  AdminCustomerServiceStatus status = AdminCustomerServiceStatus.open,
}) =>
    AdminCustomerServiceRequest(
      id: 'csr_01',
      customerIdValue: null,
      name: 'Ada Lovelace',
      email: 'ada@example.com',
      subject: subject,
      message: 'The cup arrived damaged.',
      orderReferenceValue: 'ORDER-42',
      status: status,
      resolvedAtValue: status == AdminCustomerServiceStatus.resolved
          ? DateTime.utc(2026, 9, 15, 11)
          : null,
      createdAt: DateTime.utc(2026, 9, 15, 10),
      updatedAt: DateTime.utc(2026, 9, 15, 10),
    );
