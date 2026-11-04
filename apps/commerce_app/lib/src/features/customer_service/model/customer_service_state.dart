import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/derive.dart';

part 'customer_service_state.g.dart';

/// Lifecycle of the active support form.
enum CustomerServiceStatus {
  /// No submission has started.
  idle,

  /// One request is in flight.
  submitting,

  /// The server durably accepted the request.
  succeeded,

  /// Validation, authentication, or delivery failed.
  failed,
}

/// Display-safe support failures without server internals.
enum CustomerServiceFailure {
  /// Required form content is incomplete or invalid.
  invalidInput,

  /// A stale stored session must be refreshed before retrying.
  sessionExpired,

  /// The request may succeed when retried.
  retryable,
}

/// Public support state without message content or credentials.
@Derive([ToString(), Eq(), CopyWith()])
final class CustomerServiceState with _$CustomerServiceState {
  /// Creates an empty, pending, failed, or acknowledged form state.
  const CustomerServiceState({
    this.status = CustomerServiceStatus.idle,
    this.failure = const None(),
    this.submission = const None(),
  });

  /// Classified public failure.
  final Option<CustomerServiceFailure> failure;

  /// Minimal server acknowledgement after persistence.
  final Option<CustomerServiceSubmission> submission;

  /// Current form lifecycle.
  final CustomerServiceStatus status;

  /// Whether duplicate submission must remain disabled.
  bool get isBusy => status == CustomerServiceStatus.submitting;
}
