import 'dart:async';

import 'package:commerce_server/src/features/admin_return/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Persistence required by protected merchant return routes.
final class AdminReturnDeps {
  /// Creates the focused return dependency bundle.
  AdminReturnDeps({required this.database, required this.returns});

  /// Database used for one atomic receipt transaction.
  final CommerceDatabase database;

  /// Protected return-list reads.
  final AdminReturnRepository returns;

  Future<void> _writeTail = Future<void>.value();

  /// Serializes receipt transactions on SQLite's single connection.
  Future<T> serialWrite<T>(Future<T> Function() write) {
    final previous = _writeTail;
    final completed = Completer<void>();
    _writeTail = completed.future;
    return previous.then((_) => write()).whenComplete(completed.complete);
  }
}

/// Extracts attached return dependencies or a configuration failure.
Future<Result<AdminReturnDeps, Rejection>> adminReturnDeps(Request request) =>
    stateOf<AdminReturnDeps>(request);
