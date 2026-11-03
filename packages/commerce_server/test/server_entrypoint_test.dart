import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'support/sqlx_database.dart';

void main() {
  test('production entrypoint starts, seeds, and restarts cleanly', () async {
    final directory = await Directory.systemTemp.createTemp('commerce_process');
    final databasePath = '${directory.path}/commerce.db';
    final port = await _availablePort();
    addTearDown(() => directory.delete(recursive: true));
    final databaseUrl = Platform.environment['COMMERCE_TEST_DATABASE_URL'] ??
        Platform.environment['DUST_DATABASE_URL'];
    if (databaseUrl == null || databaseUrl.isEmpty) {
      throw StateError(
        'Set COMMERCE_TEST_DATABASE_URL or DUST_DATABASE_URL for the '
        'server-entrypoint test.',
      );
    }
    final database = CommerceDatabase.connect(
      databaseUrl,
      options: commerceOptions,
    );
    await migrateCommerceDatabase(database);
    await recordSqlxHistoryForTest(
      database,
      commerceSqlxMigrationVersions,
    );
    await database.close();

    final first = await _RunningServer.start(databasePath, port);
    addTearDown(first.close);
    await first.expectReady();

    final health = await first.get('/health');
    expect(health.status, HttpStatus.ok);
    expect(jsonDecode(health.body), {'status': 'ok'});

    final catalogue = await first.get('/store/products?limit=100');
    expect(catalogue.status, HttpStatus.ok);
    final firstPage = jsonDecode(catalogue.body) as Map<String, Object?>;
    expect(firstPage['total'], 21);
    await first.close();

    final restarted = await _RunningServer.start(databasePath, port);
    addTearDown(restarted.close);
    await restarted.expectReady();

    final repeated = await restarted.get('/store/products?limit=100');
    expect(repeated.status, HttpStatus.ok);
    final repeatedPage = jsonDecode(repeated.body) as Map<String, Object?>;
    expect(repeatedPage['total'], 21);
  }, timeout: const Timeout(Duration(minutes: 1)));
}

Future<int> _availablePort() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

final class _RunningServer {
  _RunningServer(this.process, this.origin) {
    process.stdout.transform(utf8.decoder).listen(_stdout.write);
    process.stderr.transform(utf8.decoder).listen(_stderr.write);
    process.exitCode.then((code) => _exitCode = code);
  }

  static Future<_RunningServer> start(String databasePath, int port) async {
    final environment = Map<String, String>.of(Platform.environment);
    final databaseUrl = environment['COMMERCE_TEST_DATABASE_URL'] ??
        environment['DUST_DATABASE_URL'];
    if (databaseUrl == null || databaseUrl.isEmpty) {
      throw StateError(
        'Set COMMERCE_TEST_DATABASE_URL or DUST_DATABASE_URL for the '
        'server-entrypoint test.',
      );
    }
    environment['COMMERCE_DATABASE_URL'] = databaseUrl;
    environment.addAll({
      'COMMERCE_ALLOWED_ORIGINS': 'http://127.0.0.1:13001',
      'COMMERCE_BIND': '127.0.0.1',
      'COMMERCE_DATABASE_PATH': databasePath,
      'COMMERCE_PORT': '$port',
      'COMMERCE_SEED': 'true',
    });
    final process = await Process.start(
      _dartExecutable(),
      ['run', 'bin/server.dart'],
      workingDirectory: _packageRoot(),
      environment: environment,
    );
    return _RunningServer(process, 'http://127.0.0.1:$port');
  }

  final String origin;
  final Process process;
  bool _closed = false;
  int? _exitCode;
  final _stderr = StringBuffer();
  final _stdout = StringBuffer();

  Future<void> expectReady() async {
    final deadline = DateTime.now().add(const Duration(seconds: 25));
    while (DateTime.now().isBefore(deadline)) {
      final exitCode = _exitCode;
      if (exitCode != null) {
        fail('Server exited with $exitCode.\n$_stdout$_stderr');
      }
      try {
        if ((await get('/health')).status == HttpStatus.ok) return;
      } on SocketException {
        // The process is still compiling or binding its listener.
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    fail('Server did not become healthy at $origin');
  }

  Future<_HttpResponse> get(String path) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse('$origin$path'));
      final response = await request.close();
      return _HttpResponse(
        response.statusCode,
        await response.transform(utf8.decoder).join(),
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final exited = _exitCode;
    if (exited != null) {
      expect(exited, 0, reason: '$_stdout$_stderr');
      return;
    }
    expect(process.kill(ProcessSignal.sigterm), isTrue);
    final code = await process.exitCode.timeout(const Duration(seconds: 20));
    expect(code, 0);
  }
}

String _dartExecutable() {
  final resolved = File(Platform.resolvedExecutable);
  final suffix = Platform.isWindows ? '.exe' : '';
  final sdkDart =
      File('${resolved.parent.path}/cache/dart-sdk/bin/dart$suffix');
  return sdkDart.existsSync() ? sdkDart.path : resolved.path;
}

String _packageRoot() {
  final current = Directory.current.absolute;
  if (File('${current.path}/bin/server.dart').existsSync()) return current.path;

  final workspacePackage =
      Directory('${current.path}/packages/commerce_server');
  if (File('${workspacePackage.path}/bin/server.dart').existsSync()) {
    return workspacePackage.path;
  }
  throw StateError('Could not find the commerce_server package root.');
}

final class _HttpResponse {
  const _HttpResponse(this.status, this.body);

  final String body;
  final int status;
}
