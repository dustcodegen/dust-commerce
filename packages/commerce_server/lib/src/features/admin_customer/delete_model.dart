import 'package:dust_dart/db.dart';

part 'delete_model.g.dart';

/// Internal account-ownership facts needed before deleting a customer.
@Derive([FromRow()])
final class AdminCustomerDeleteContext {
  /// Creates one direct SQLx deletion projection.
  const AdminCustomerDeleteContext({
    required this.authIdentityId,
    required this.authIdentityCount,
    required this.hasAccountValue,
    required this.hasOtherActorValue,
  });

  /// The one active identity linked to this customer, when present.
  @Sqlx(rename: 'auth_identity_id')
  final String? authIdentityId;

  /// Number of active identities claiming this customer actor.
  @Sqlx(rename: 'auth_identity_count')
  final int authIdentityCount;

  /// Raw SQLite account flag.
  @Sqlx(rename: 'has_account')
  final int hasAccountValue;

  /// Whether the linked identity owns another non-null actor.
  @Sqlx(rename: 'has_other_actor')
  final int hasOtherActorValue;

  /// Whether this profile owns sign-in capability.
  bool get hasAccount => hasAccountValue == 1;

  /// Whether deleting the customer must preserve the auth identity.
  bool get hasOtherActor => hasOtherActorValue == 1;
}
