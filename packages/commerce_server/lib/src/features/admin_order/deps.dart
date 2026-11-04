import 'dart:async';

import 'package:commerce_server/src/features/admin_order/repository.dart';
import 'package:commerce_server/src/features/admin_order/detail_repository.dart';
import 'package:commerce_server/src/features/admin_order/export_repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Persistence required only by merchant order routes.
final class AdminOrderDeps {
  /// Creates the focused order dependency bundle.
  AdminOrderDeps({
    required this.orders,
    required this.details,
    required this.exports,
    required this.database,
    required this.nextId,
  });

  /// Database used for one atomic fulfillment transaction.
  final CommerceDatabase database;

  /// Complete protected order snapshot reads.
  final AdminOrderDetailRepository details;

  /// Complete filtered order/item reads used only by CSV export.
  final AdminOrderExportRepository exports;

  /// Shared opaque identifier source; SQLite owns all timestamps.
  final String Function() nextId;

  /// Protected order-list reads.
  final AdminOrderRepository orders;

  Future<void> _writeTail = Future<void>.value();

  /// Serializes fulfillment transactions on SQLite's single connection.
  Future<T> serialWrite<T>(Future<T> Function() write) {
    final previous = _writeTail;
    final completed = Completer<void>();
    _writeTail = completed.future;
    return previous.then((_) => write()).whenComplete(completed.complete);
  }
}

/// Extracts attached order dependencies or returns a configuration failure.
Future<Result<AdminOrderDeps, Rejection>> adminOrderDeps(Request request) =>
    stateOf<AdminOrderDeps>(request);
