import 'package:dust_dart/derive.dart';

part 'admin_promotion_create_state.g.dart';

/// Lifecycle of the promotion creation command.
enum AdminPromotionCreateStatus {
  /// No command is running.
  idle,

  /// The server is validating and committing the promotion.
  submitting,

  /// The command failed with display-safe copy.
  failed,
}

/// Immutable state for the focused promotion form.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminPromotionCreateState with _$AdminPromotionCreateState {
  /// Creates an idle form state.
  const AdminPromotionCreateState({
    this.status = AdminPromotionCreateStatus.idle,
    this.failure = const None(),
  });

  /// Display-safe server or transport failure.
  final Option<String> failure;

  /// Current command lifecycle.
  final AdminPromotionCreateStatus status;

  /// Whether the form is submitting.
  bool get isBusy => status == AdminPromotionCreateStatus.submitting;
}
