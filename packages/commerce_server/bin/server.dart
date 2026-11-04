import 'dart:async';
import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:dust_server/server.dart';

Future<void> main() async {
  final config = _ServerConfig.fromEnvironment(Platform.environment);
  final mailConfig = OrderTransferMailConfig.optionFromEnvironment(
    Platform.environment,
  );
  final transferMailer = mailConfig.match<OrderTransferMailer>(
    some: (value) => value.build(),
    none: UnavailableOrderTransferMailer.new,
  );
  final verificationMailer = mailConfig.match<EmailVerificationMailer>(
    some: (value) => value.buildEmailVerification(),
    none: UnavailableEmailVerificationMailer.new,
  );
  if (config.requireEmailVerification && !verificationMailer.isAvailable) {
    throw const FormatException(
      'SMTP settings are required when email verification is enabled.',
    );
  }
  final database = CommerceDatabase.connect(
    config.databaseUrl,
    options: commerceOptions,
  );
  final mediaStorage = LocalAdminMediaStorage(
    root: Directory(config.mediaPath),
    publicBaseUrl: config.publicBaseUrl,
    nextKey: () => 'media_${Tokens.issue()}',
  );
  await mediaStorage.prepare();

  try {
    await migrateCommerceDatabase(database);
    if (config.seed) {
      await seedDevelopmentStore(database);
      await seedDevelopmentDemoCatalog(database);
      await seedDevelopmentSupportInbox(database);
    }
    final app = buildApp(
      database,
      emailVerificationMailer: verificationMailer,
      orderTransferMailer: transferMailer,
      mediaStorage: mediaStorage,
      requireEmailVerification: config.requireEmailVerification,
    )
      ..layer(const SecurityHeaders())
      ..layer(const RequestId());
    if (config.allowedOrigins.isNotEmpty) {
      app.layer(storefrontCors(config.allowedOrigins));
    }

    final server = await serve(app, config.address, config.port);
    stdout.writeln('dust-commerce listening on http://'
        '${server.address.host}:${server.port}');

    await _waitForShutdownSignal();
    final drained = await server.close(drain: const Duration(seconds: 15));
    if (!drained) {
      stderr.writeln(
        'Shutdown deadline passed with ${server.inFlight} request(s) active.',
      );
      exitCode = 1;
    }
  } finally {
    await database.close();
  }
}

Future<void> _waitForShutdownSignal() async {
  final signal = Completer<void>();
  final subscriptions = <StreamSubscription<ProcessSignal>>[];

  void stop(ProcessSignal _) {
    if (!signal.isCompleted) signal.complete();
  }

  subscriptions
    ..add(ProcessSignal.sigterm.watch().listen(stop))
    ..add(ProcessSignal.sigint.watch().listen(stop));
  await signal.future;
  await Future.wait(subscriptions.map((subscription) => subscription.cancel()));
}

final class _ServerConfig {
  const _ServerConfig({
    required this.address,
    required this.port,
    required this.databaseUrl,
    required this.mediaPath,
    required this.publicBaseUrl,
    required this.requireEmailVerification,
    required this.seed,
    required this.allowedOrigins,
  });

  factory _ServerConfig.fromEnvironment(Map<String, String> environment) {
    final bind = environment['COMMERCE_BIND'] ?? '127.0.0.1';
    final portText = environment['COMMERCE_PORT'] ?? '3878';
    final port = int.tryParse(portText);
    if (port == null || port < 1 || port > 65535) {
      throw FormatException('COMMERCE_PORT must be between 1 and 65535.');
    }

    return _ServerConfig(
      address: InternetAddress(bind),
      port: port,
      databaseUrl: _databaseUrl(environment),
      mediaPath: environment['COMMERCE_MEDIA_PATH'] ?? '.data/media',
      publicBaseUrl: _publicBaseUrl(
        environment['COMMERCE_PUBLIC_BASE_URL'],
        bind,
        port,
      ),
      requireEmailVerification: _boolean(
        environment,
        'COMMERCE_REQUIRE_EMAIL_VERIFICATION',
      ),
      seed: environment['COMMERCE_SEED'] == 'true',
      allowedOrigins: {
        for (final origin
            in (environment['COMMERCE_ALLOWED_ORIGINS'] ?? '').split(','))
          if (origin.trim().isNotEmpty) origin.trim(),
      },
    );
  }

  final InternetAddress address;
  final Set<String> allowedOrigins;
  final String databaseUrl;
  final String mediaPath;
  final int port;
  final Uri publicBaseUrl;
  final bool requireEmailVerification;
  final bool seed;

  static String _databaseUrl(Map<String, String> environment) {
    final value = environment['COMMERCE_DATABASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw const FormatException(
        'COMMERCE_DATABASE_URL must be set to a PostgreSQL connection URL.',
      );
    }
    final uri = Uri.tryParse(value);
    if (uri == null ||
        (uri.scheme != 'postgres' && uri.scheme != 'postgresql')) {
      throw const FormatException(
        'COMMERCE_DATABASE_URL must use postgres:// or postgresql://.',
      );
    }
    return value;
  }

  static bool _boolean(Map<String, String> source, String key) =>
      switch (source[key]) {
        null || 'false' => false,
        'true' => true,
        _ => throw FormatException('$key must be true or false.'),
      };

  static Uri _publicBaseUrl(String? configured, String bind, int port) {
    final localHost = bind == '0.0.0.0' || bind == '::' ? '127.0.0.1' : bind;
    final value = configured?.trim().isNotEmpty == true
        ? configured!.trim()
        : Uri(scheme: 'http', host: localHost, port: port).toString();
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.userInfo.isNotEmpty ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty) {
      throw const FormatException(
        'COMMERCE_PUBLIC_BASE_URL must be an absolute HTTP(S) origin.',
      );
    }
    return uri;
  }
}
