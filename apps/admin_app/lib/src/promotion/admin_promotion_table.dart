import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Compact promotion table with Medusa's visible columns.
final class AdminPromotionTable extends StatelessWidget {
  /// Creates promotion rows.
  const AdminPromotionTable({
    required this.promotions,
    required this.onOpen,
    super.key,
  });

  /// Opens one promotion detail route.
  final ValueChanged<String> onOpen;

  /// Explicit rows from the Admin contract.
  final List<AdminPromotion> promotions;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _AdminPromotionTableHeader(),
          for (final promotion in promotions)
            _AdminPromotionTableRow(promotion: promotion, onOpen: onOpen),
        ],
      );
}

final class _AdminPromotionTableHeader extends StatelessWidget {
  const _AdminPromotionTableHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(children: [
          Expanded(flex: 4, child: Text('Code')),
          Expanded(flex: 3, child: Text('Method')),
          Expanded(flex: 3, child: Text('Status')),
          Expanded(flex: 3, child: Text('Created')),
        ]),
      );
}

final class _AdminPromotionTableRow extends StatelessWidget {
  const _AdminPromotionTableRow({
    required this.promotion,
    required this.onOpen,
  });

  final ValueChanged<String> onOpen;
  final AdminPromotion promotion;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onOpen(promotion.id),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(children: [
              Expanded(flex: 4, child: Text(promotion.code)),
              Expanded(flex: 3, child: Text(_method)),
              Expanded(flex: 3, child: _StatusBadge(status: promotion.status)),
              Expanded(
                flex: 3,
                child: Text(
                  DateFormat.yMMMd().format(promotion.createdAt.toLocal()),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ]),
          ),
        ),
      );

  String get _method => promotion.isAutomatic ? 'Automatic' : 'Code';
}

final class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AdminPromotionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AdminPromotionStatus.active => Colors.green,
      AdminPromotionStatus.scheduled => Colors.orange,
      AdminPromotionStatus.expired => Theme.of(context).colorScheme.error,
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            _label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }

  String get _label => switch (status) {
        AdminPromotionStatus.active => 'Active',
        AdminPromotionStatus.scheduled => 'Scheduled',
        AdminPromotionStatus.expired => 'Expired',
      };
}
