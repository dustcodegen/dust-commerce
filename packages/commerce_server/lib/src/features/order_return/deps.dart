import 'dart:async';

import 'package:commerce_server/src/features/order_return/repository/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Dependencies for atomic, customer-owned return requests.
final class OrderReturnDeps {
  /// Creates the return dependency bundle.
  OrderReturnDeps({
    required this.database,
    required this.reads,
    required this.lists,
    required this.creates,
    required this.clock,
  });

  /// Identifier source shared with other Store operations.
  final Clock clock;

  /// Inserts request roots and items.
  final OrderReturnCreateRepository creates;

  /// Database used for one atomic validation/write transaction.
  final CommerceDatabase database;

  /// Public active return-reason discovery.
  final OrderReturnListRepository lists;

  /// Owned order, item, reason and response reads.
  final OrderReturnReadRepository reads;

  Future<void> _writeTail = Future<void>.value();

  /// Serializes return transactions on SQLite's single connection.
  Future<T> serialWrite<T>(Future<T> Function() write) {
    final previous = _writeTail;
    final completed = Completer<void>();
    _writeTail = completed.future;
    return previous.then((_) => write()).whenComplete(completed.complete);
  }
}

/// Attached return dependencies, or a configuration 500.
Future<Result<OrderReturnDeps, Rejection>> orderReturnDeps(Request request) =>
    stateOf<OrderReturnDeps>(request);
