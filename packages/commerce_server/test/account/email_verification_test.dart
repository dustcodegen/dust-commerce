import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late RecordingEmailVerificationMailer mailer;
  late TestClient client;
  late DateTime currentTime;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('email_verification');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    mailer = RecordingEmailVerificationMailer();
    currentTime = DateTime.now().toUtc();
    var id = 0;
    client = TestClient(buildApp(
      database,
      nextId: () => 'id_${++id}',
      now: () => currentTime,
      emailVerificationMailer: mailer,
      requireEmailVerification: true,
    ));
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('registration emails one single-use verification capability', () async {
    final registration = await _register(client);
    registration.assertCreated();
    expect(mailer.messages, hasLength(1));
    expect(mailer.messages.single.recipient, 'ada@example.com');
    final firstToken = mailer.messages.single.token;

    final before = await _signIn(client);
    before.assertForbidden();
    expect(mailer.messages, hasLength(2));
    final token = mailer.messages.last.token;

    final replaced =
        await (client.post('/auth/customer/emailpass/verification/confirm')
              ..json({'token': firstToken}))
            .send();
    replaced.assertNotFound();

    final verified =
        await (client.post('/auth/customer/emailpass/verification/confirm')
              ..json({'token': token}))
            .send();
    verified
      ..assertOk()
      ..assertJsonContains({'success': true});

    final replay =
        await (client.post('/auth/customer/emailpass/verification/confirm')
              ..json({'token': token}))
            .send();
    replay.assertNotFound();
    _issuedToken(await _signIn(client));
  });

  test('expired and unknown capabilities share the same response', () async {
    await _register(client);
    final expired = mailer.messages.single.token;
    currentTime = currentTime.add(const Duration(days: 2));

    final expiredResponse =
        await (client.post('/auth/customer/emailpass/verification/confirm')
              ..json({'token': expired}))
            .send();
    final unknownResponse =
        await (client.post('/auth/customer/emailpass/verification/confirm')
              ..json({
                'token': '00000000000000000000000000000000'
                    '00000000000000000000000000000000',
              }))
            .send();

    expect(expiredResponse.statusCode, unknownResponse.statusCode);
  });

  test('disabled verification keeps existing account behavior', () async {
    await client.close();
    client = TestClient(buildApp(database));
    (await _register(client)).assertCreated();
    _issuedToken(await _signIn(client));
  });
}

Future<TestResponse> _register(TestClient client) =>
    (client.post('/store/customers')
          ..json({
            'email': ' Ada@Example.COM ',
            'password': 'correct horse battery staple',
          }))
        .send();

Future<TestResponse> _signIn(TestClient client) =>
    (client.post('/auth/customer/emailpass')
          ..json({
            'email': 'ada@example.com',
            'password': 'correct horse battery staple',
          }))
        .send();

void _issuedToken(TestResponse response) {
  response.assertOk();
  expect((response.json! as Map<String, Object?>)['token'], isNotEmpty);
}

final class RecordingEmailVerificationMailer
    implements EmailVerificationMailer {
  final messages = <EmailVerificationMail>[];

  @override
  bool get isAvailable => true;

  @override
  Future<void> send(EmailVerificationMail mail) async => messages.add(mail);
}
