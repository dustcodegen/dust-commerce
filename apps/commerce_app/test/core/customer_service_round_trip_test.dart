import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated client submits a guest support request', () async {
    final directory = await Directory.systemTemp.createTemp('support_client');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    final server = await TestClient.serve(buildApp(
      database,
      nextId: () => 'support_1',
    ));
    final api = CommerceApi(Dio(), baseUrl: server.origin);
    addTearDown(() async {
      await server.close();
      await database.close();
      await directory.delete(recursive: true);
    });

    final submission = await api.submitCustomerService(
      const CustomerServiceRequestBody(
        name: 'Ada Lovelace',
        email: 'ada@example.com',
        subject: 'Order question',
        message: 'Can you help with order 42?',
        orderReferenceValue: '42',
      ),
    );

    expect(submission.id, 'support_1');
    expect(submission.createdAt.isUtc, isTrue);
  });
}
