import 'package:commerce_server/src/features/admin_refund/failure.dart';
import 'package:commerce_server/src/features/admin_refund/payment_model.dart';

/// Transaction outcome keeps business refusal out of SQLx's error channel.
sealed class AdminPaymentRefundOutcome {
  const AdminPaymentRefundOutcome();
}

/// Successful committed refund and refreshed payment.
final class AdminPaymentRefundReady extends AdminPaymentRefundOutcome {
  /// Creates a successful transaction result.
  const AdminPaymentRefundReady(this.response);

  /// Direct SQLx response returned to Admin.
  final AdminRefundedPaymentResponse response;
}

/// Expected business refusal that causes no commit.
final class AdminPaymentRefundDenied extends AdminPaymentRefundOutcome {
  /// Creates a denied transaction result.
  const AdminPaymentRefundDenied(this.failure);

  /// Stable refusal reason.
  final AdminPaymentRefundFailure failure;
}
