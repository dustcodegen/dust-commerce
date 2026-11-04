import 'package:commerce_server/src/features/order_transfer/mail.dart';
import 'package:commerce_server/src/features/order_transfer/repository/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Dependencies for order-transfer ownership and delivery.
final class OrderTransferDeps {
  /// Creates the transfer dependency bundle.
  const OrderTransferDeps({
    required this.database,
    required this.reads,
    required this.creates,
    required this.updates,
    required this.clock,
    required this.mailer,
  });

  /// Clock and identifier source shared with other customer operations.
  final Clock clock;

  /// Inserts new transfer requests.
  final OrderTransferCreateRepository creates;

  /// Database used for atomic ownership transitions.
  final CommerceDatabase database;

  /// Configured outbound transfer email adapter.
  final OrderTransferMailer mailer;

  /// Transfer and order lookups.
  final OrderTransferReadRepository reads;

  /// Delivery leases and ownership decisions.
  final OrderTransferUpdateRepository updates;
}

/// Attached transfer dependencies, or a configuration 500.
Future<Result<OrderTransferDeps, Rejection>> orderTransferDeps(
  Request request,
) =>
    stateOf<OrderTransferDeps>(request);
