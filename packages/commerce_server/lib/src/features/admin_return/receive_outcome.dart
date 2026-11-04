import 'package:commerce_server/src/features/admin_return/model.dart';
import 'package:commerce_server/src/features/admin_return/receive_failure.dart';

/// Transaction value keeping domain refusal out of nested Result types.
sealed class AdminReturnReceiveOutcome {
  const AdminReturnReceiveOutcome();
}

/// Persisted receipt and its refreshed direct-SQLx response.
final class AdminReturnReceiveReady extends AdminReturnReceiveOutcome {
  /// Creates a successful receipt outcome.
  const AdminReturnReceiveReady(this.response);

  /// Refreshed return response.
  final AdminReturnResponse response;
}

/// Expected refusal that rolls the transaction back without storage loss.
final class AdminReturnReceiveDenied extends AdminReturnReceiveOutcome {
  /// Creates a denied receipt outcome.
  const AdminReturnReceiveDenied(this.failure);

  /// Stable business reason.
  final AdminReturnReceiveFailure failure;
}
