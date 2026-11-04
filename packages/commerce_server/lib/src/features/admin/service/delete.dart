import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:dust_dart/db.dart';

/// Revokes a raw admin bearer by deleting only its fingerprint.
Future<Result<ExecResult, SqlxError>> adminSignOut(
  AdminDeleteRepository deletes,
  String token,
) =>
    Tokens.fingerprint(token).then(deletes.revokeToken);
