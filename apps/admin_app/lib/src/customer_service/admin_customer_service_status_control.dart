import 'dart:async';

import 'package:admin_app/src/customer_service/admin_customer_service_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Compact request-status badge with the lifecycle update menu.
final class AdminCustomerServiceStatusControl extends StatelessWidget {
  /// Creates a lifecycle control for [request].
  const AdminCustomerServiceStatusControl({
    required this.request,
    this.onUpdated,
    super.key,
  });

  /// Runs after a successful lifecycle replacement.
  final VoidCallback? onUpdated;

  /// Request whose lifecycle is shown and changed.
  final AdminCustomerServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminCustomerServiceViewModel().value;
    final busy = state.isUpdating(request.id);
    return PopupMenuButton<AdminCustomerServiceStatus>(
      enabled: !busy,
      tooltip: 'Change status',
      onSelected: (status) => unawaited(_update(context, status)),
      itemBuilder: (context) => [
        for (final status in AdminCustomerServiceStatus.values)
          PopupMenuItem(
            value: status,
            enabled: status != request.status,
            child: Text(adminCustomerServiceStatusLabel(status)),
          ),
      ],
      child: AdminCustomerServiceStatusBadge(
        status: request.status,
        busy: busy,
      ),
    );
  }

  Future<void> _update(
    BuildContext context,
    AdminCustomerServiceStatus status,
  ) async {
    final changed = await context
        .readAdminCustomerServiceViewModel()
        .updateStatus(request.id, status);
    if (changed) onUpdated?.call();
  }
}

/// Read-only lifecycle badge used inside the update control.
final class AdminCustomerServiceStatusBadge extends StatelessWidget {
  /// Creates the visual status indicator.
  const AdminCustomerServiceStatusBadge({
    required this.status,
    this.busy = false,
    super.key,
  });

  /// Whether an update is active.
  final bool busy;

  /// Current persisted lifecycle.
  final AdminCustomerServiceStatus status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: _statusColor(status).withValues(alpha: .12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy) ...[
              const SizedBox.square(
                dimension: 10,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              adminCustomerServiceStatusLabel(status),
              style: TextStyle(
                color: _statusColor(status),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

/// Merchant-facing lifecycle label.
String adminCustomerServiceStatusLabel(AdminCustomerServiceStatus status) =>
    switch (status) {
      AdminCustomerServiceStatus.open => 'Open',
      AdminCustomerServiceStatus.inProgress => 'In progress',
      AdminCustomerServiceStatus.resolved => 'Resolved',
    };

Color _statusColor(AdminCustomerServiceStatus status) => switch (status) {
      AdminCustomerServiceStatus.open => const Color(0xFFB54708),
      AdminCustomerServiceStatus.inProgress => const Color(0xFF175CD3),
      AdminCustomerServiceStatus.resolved => const Color(0xFF027A48),
    };
