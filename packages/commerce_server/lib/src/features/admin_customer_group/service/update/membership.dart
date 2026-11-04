import 'dart:convert';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer_group/detail_response.dart';
import 'package:commerce_server/src/features/admin_customer_group/repository/read.dart';
import 'package:commerce_server/src/features/admin_customer_group/repository/update/membership.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';

/// Business reason a customer-group membership batch is rejected.
enum AdminCustomerGroupMembershipFailure {
  /// The batch is empty, duplicated, overlapping, oversized, or malformed.
  invalidBatch,

  /// At least one supplied customer is missing or retired.
  invalidCustomers,

  /// Persistence failed and the transaction was rolled back.
  database,
}

/// Applies one Medusa-compatible add/remove membership batch atomically.
Future<
        Result<Option<AdminCustomerGroupDetailResult>,
            AdminCustomerGroupMembershipFailure>>
    updateAdminCustomerGroupMemberships(
  CommerceDatabase database,
  String groupId,
  AdminBatchCustomerGroupCustomers input, {
  required String createdBy,
  required String Function() nextId,
}) async {
  final add = input.add.toSet();
  final remove = input.remove.toSet();
  if (add.length != input.add.length ||
      remove.length != input.remove.length ||
      add.intersection(remove).isNotEmpty ||
      add.length + remove.length == 0 ||
      add.length + remove.length > 500 ||
      [...add, ...remove].any((id) => id.trim().isEmpty)) {
    return const Err(AdminCustomerGroupMembershipFailure.invalidBatch);
  }

  final decision = await database.transaction<_MembershipDecision>((tx) async {
    final memberships = AdminCustomerGroupMembershipRepository(tx);
    final groupCount = await memberships.activeGroupCount(groupId);
    if (groupCount case Err(:final error)) return Err(error);
    if ((groupCount as Ok<int, SqlxError>).value != 1) {
      return const Ok(_MembershipGroupNotFound());
    }

    final ids = [...add, ...remove];
    final customerCount =
        await memberships.activeCustomerCount(jsonEncode(ids));
    if (customerCount case Err(:final error)) return Err(error);
    if ((customerCount as Ok<int, SqlxError>).value != ids.length) {
      return const Ok(_MembershipInvalidCustomers());
    }

    if (remove.isNotEmpty) {
      final removed =
          await memberships.remove(groupId, jsonEncode(remove.toList()));
      if (removed case Err(:final error)) return Err(error);
    }
    if (add.isNotEmpty) {
      final rows = [
        for (final customerId in add)
          {'id': nextId(), 'customer_id': customerId},
      ];
      final added = await memberships.add(groupId, createdBy, jsonEncode(rows));
      if (added case Err(:final error)) return Err(error);
    }

    final refreshed =
        await AdminCustomerGroupDetailRepository(tx).find(groupId);
    return switch (refreshed) {
      Ok(value: final value?) => Ok(_MembershipChanged(
          AdminCustomerGroupDetailResult(customerGroup: value),
        )),
      Ok(value: null) => const Ok(_MembershipGroupNotFound()),
      Err(:final error) => Err(error),
    };
  });

  return switch (decision) {
    Ok(value: _MembershipChanged(:final result)) => Ok(Some(result)),
    Ok(value: _MembershipGroupNotFound()) => const Ok(None()),
    Ok(value: _MembershipInvalidCustomers()) =>
      const Err(AdminCustomerGroupMembershipFailure.invalidCustomers),
    Err() => const Err(AdminCustomerGroupMembershipFailure.database),
  };
}

sealed class _MembershipDecision {
  const _MembershipDecision();
}

final class _MembershipChanged extends _MembershipDecision {
  const _MembershipChanged(this.result);

  final AdminCustomerGroupDetailResult result;
}

final class _MembershipGroupNotFound extends _MembershipDecision {
  const _MembershipGroupNotFound();
}

final class _MembershipInvalidCustomers extends _MembershipDecision {
  const _MembershipInvalidCustomers();
}
