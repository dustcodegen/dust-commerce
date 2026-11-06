import 'package:commerce_server/src/features/admin_refund/reason_repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// Dependencies for protected merchant refund-reason routes.
final class AdminRefundReasonDeps {
  /// Creates the refund-reason dependency bundle.
  const AdminRefundReasonDeps({required this.reasons, required this.clock});

  /// Direct SQLx reason persistence.
  final AdminRefundReasonRepository reasons;

  /// Database-owned id source for new reasons.
  final Clock clock;
}

/// Extracts refund-reason dependencies from route state.
Future<Result<AdminRefundReasonDeps, Rejection>> adminRefundReasonDeps(
  Request request,
) =>
    stateOf<AdminRefundReasonDeps>(request);
