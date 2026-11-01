import 'dart:io';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';

Future<void> main() async {
  final environment = Platform.environment;
  final email = environment['COMMERCE_ADMIN_EMAIL'];
  final password = environment['COMMERCE_ADMIN_PASSWORD'];
  if (email == null || password == null) {
    stderr.writeln(
      'Set COMMERCE_ADMIN_EMAIL and COMMERCE_ADMIN_PASSWORD. '
      'The password is intentionally not accepted as a command argument.',
    );
    exitCode = 64;
    return;
  }

  final credentials = AdminCredentials.fromJson({
    'email': email,
    'password': password,
  });
  if (credentials.validate() case Invalid(:final errors)) {
    for (final error in errors) {
      stderr.writeln('${error.field}: ${error.message}');
    }
    exitCode = 64;
    return;
  }

  final databaseUrl = environment['COMMERCE_DATABASE_URL'];
  if (databaseUrl == null || databaseUrl.trim().isEmpty) {
    stderr.writeln('Set COMMERCE_DATABASE_URL to a PostgreSQL connection URL.');
    exitCode = 64;
    return;
  }
  final database = CommerceDatabase.connect(
    databaseUrl,
    options: commerceOptions,
  );
  try {
    await migrateCommerceDatabase(database);
    final result = await bootstrapAdmin(
      database,
      credentials,
      nextId: () => 'id_${Tokens.issue()}',
      passwordWork: PasswordWorkLimiter(),
      firstName: _optional(environment['COMMERCE_ADMIN_FIRST_NAME']),
      lastName: _optional(environment['COMMERCE_ADMIN_LAST_NAME']),
    );
    switch (result) {
      case Ok(value: Ok()):
        stdout.writeln('Admin ready.');
      case Ok(value: Err(error: AdminBootstrapFailure.alreadyExists)):
        stdout.writeln('Admin already exists.');
      case Err():
        stderr.writeln('Could not create the admin account.');
        exitCode = 1;
    }
  } finally {
    await database.close();
  }
}

String? _optional(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
