import 'dart:convert';

import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('media mutations require an admin bearer', () async {
    final upload = harness.client.post('/admin/uploads')
      ..bytes(
        multipartFiles('auth', pngBytes),
        contentType: 'multipart/form-data; boundary=auth',
      );

    (await upload.send()).assertUnauthorized();
    (await harness.client.delete('/admin/uploads/test_media_1.png').send())
        .assertUnauthorized();
  });

  test('uploads, publicly reads, and discards staged media', () async {
    final uploaded = await harness.uploadPng();
    expect(uploaded, {
      'id': 'test_media_1.png',
      'url': 'http://media.test/uploads/test_media_1.png',
      'filename': 'product.png',
      'mime_type': 'image/png',
      'size': pngBytes.length,
    });

    final read = await harness.client.get('/uploads/test_media_1.png').send();
    read
      ..assertOk()
      ..assertHeader('content-type', 'image/png')
      ..assertHeader('content-length', '${pngBytes.length}')
      ..assertHeader('cache-control', 'public, max-age=31536000, immutable');
    expect(read.bodyBytes, pngBytes);

    final token = await harness.adminToken();
    final remove = harness.client.delete('/admin/uploads/test_media_1.png')
      ..bearer(token);
    (await remove.send()).assertNoContent();
    (await harness.client.get('/uploads/test_media_1.png').send())
        .assertNotFound();
  });

  test('rejects invalid or excessive uploads without leftovers', () async {
    final token = await harness.adminToken();
    for (final request in [
      harness.client.post('/admin/uploads')
        ..bearer(token)
        ..bytes(
          multipartFiles('invalid', utf8.encode('not an image')),
          contentType: 'multipart/form-data; boundary=invalid',
        ),
      harness.client.post('/admin/uploads')
        ..bearer(token)
        ..bytes(
          multipartFiles('many', pngBytes, count: 11),
          contentType: 'multipart/form-data; boundary=many',
        ),
    ]) {
      (await request.send()).assertUnprocessable();
      expect(harness.mediaDirectory.listSync(), isEmpty);
    }
  });
}
