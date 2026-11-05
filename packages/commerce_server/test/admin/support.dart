import 'dart:convert';
import 'dart:io';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

/// Real app and temporary database used by admin route tests.
final class AdminHarness {
  AdminHarness._(
    this.directory,
    this.mediaDirectory,
    this.database,
    this.client,
  );

  /// Synthetic password used only inside temporary test databases.
  static const password = 'correct horse battery staple';

  /// Starts a migrated app with one bootstrapped administrator.
  static Future<AdminHarness> start({bool seedStore = false}) async {
    final directory = await Directory.systemTemp.createTemp('commerce_admin');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    var bootstrapId = 0;
    final created = await bootstrapAdmin(
      database,
      const AdminCredentials(
        email: ' OWNER@EXAMPLE.COM ',
        password: password,
      ),
      nextId: () => 'admin_${++bootstrapId}',
      passwordWork: PasswordWorkLimiter(),
      firstName: 'Store',
      lastName: 'Owner',
    );
    if (created case Ok()) {
      // Start only after the non-public bootstrap succeeds.
    } else {
      fail('Admin bootstrap failed: $created');
    }
    if (seedStore) await seedDevelopmentStore(database);
    var requestId = 100;
    var mediaId = 0;
    final mediaDirectory = Directory('${directory.path}/media');
    final mediaStorage = LocalAdminMediaStorage(
      root: mediaDirectory,
      publicBaseUrl: Uri.parse('http://media.test'),
      nextKey: () => 'test_media_${++mediaId}',
    );
    await mediaStorage.prepare();
    return AdminHarness._(
      directory,
      mediaDirectory,
      database,
      TestClient(buildApp(
        database,
        nextId: () => 'id_${++requestId}',
        now: () => DateTime.utc(2100, 1, 1, 12),
        mediaStorage: mediaStorage,
      )),
    );
  }

  /// In-memory request client.
  final TestClient client;

  /// Temporary migrated database.
  final CommerceDatabase database;

  /// Temporary product-media directory.
  final Directory mediaDirectory;

  /// Temporary directory deleted by [stop].
  final Directory directory;

  /// Sends one admin password exchange.
  Future<TestResponse> signIn({
    String email = 'owner@example.com',
    String password = AdminHarness.password,
  }) =>
      (client.post('/auth/admin/emailpass')
            ..json({'email': email, 'password': password}))
          .send();

  /// Returns one valid raw token for request tests.
  Future<String> adminToken() async {
    final response = await signIn();
    response.assertOk();
    return (response.json! as Map<String, Object?>)['token']! as String;
  }

  /// Uploads the minimal PNG fixture through the protected multipart route.
  Future<Map<String, Object?>> uploadPng() async {
    final token = await adminToken();
    final request = client.post('/admin/uploads')
      ..bearer(token)
      ..bytes(
        multipartFiles('upload', pngBytes),
        contentType: 'multipart/form-data; boundary=upload',
      );
    final response = await request.send();
    response.assertCreated();
    final body = response.json! as Map<String, Object?>;
    return (body['files']! as List<Object?>).single! as Map<String, Object?>;
  }

  /// Executes a read-only assertion query.
  Future<List<Row>> raw(String sql) =>
      queryRaw(sql, []).fetch(database.connection as Executor);

  /// Closes and removes every temporary resource.
  Future<void> stop() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  }
}

/// Minimal signature-valid PNG fixture used by media boundary tests.
const pngBytes = <int>[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];

/// Encodes repeated binary files as a standards-compliant multipart body.
List<int> multipartFiles(String boundary, List<int> bytes, {int count = 1}) => [
      for (var index = 0; index < count; index++) ...[
        ...utf8.encode(
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="files"; filename="product.png"\r\n'
          'Content-Type: image/png\r\n\r\n',
        ),
        ...bytes,
        ...utf8.encode('\r\n'),
      ],
      ...utf8.encode('--$boundary--\r\n'),
    ];
