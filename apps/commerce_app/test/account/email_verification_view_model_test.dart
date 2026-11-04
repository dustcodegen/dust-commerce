import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late _RecordingMailer mailer;
  late CommerceApi api;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('verify_email_model');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    mailer = _RecordingMailer();
    server = await TestClient.serve(buildApp(
      database,
      emailVerificationMailer: mailer,
      requireEmailVerification: true,
    ));
    api = CommerceApi(Dio(), baseUrl: server.origin);
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('consumes a valid email capability once', () async {
    await api.registerAccount(const RegisterAccountBody(
      email: 'ada@example.com',
      password: 'correct horse battery staple',
    ));
    final model = EmailVerificationViewModel(
      EmailVerificationViewModelArgs(api: api),
    );

    expect(await model.verify(mailer.messages.single.token), isTrue);
    expect(model.state.status, EmailVerificationStatus.success);
    expect(await model.verify(mailer.messages.single.token), isFalse);
    expect(model.state.status, EmailVerificationStatus.failed);
  });

  test('registration waits without persisting a customer session', () async {
    final sessions = MemoryAuthSessionStore();
    final account = AccountViewModel(
      AccountViewModelArgs(api: api, sessions: sessions),
    );

    expect(
      await account.register(
        email: 'ada@example.com',
        password: 'correct horse battery staple',
        firstName: 'Ada',
        lastName: 'Lovelace',
      ),
      isTrue,
    );
    expect(account.state.status, AccountStatus.verificationRequired);
    expect(account.state.verificationEmail.unwrapOr(''), 'ada@example.com');
    expect(sessions.value, isNull);
    expect(mailer.messages, hasLength(1));
  });

  test('rejects a missing capability without a request', () async {
    final model = EmailVerificationViewModel(
      EmailVerificationViewModelArgs(api: api),
    );

    expect(await model.verify(''), isFalse);
    expect(model.state.status, EmailVerificationStatus.failed);
  });
}

final class _RecordingMailer implements EmailVerificationMailer {
  final messages = <EmailVerificationMail>[];

  @override
  bool get isAvailable => true;

  @override
  Future<void> send(EmailVerificationMail mail) async => messages.add(mail);
}
