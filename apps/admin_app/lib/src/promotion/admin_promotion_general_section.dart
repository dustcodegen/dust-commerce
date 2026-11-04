import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// General promotion identity matching the current read-only slice.
final class AdminPromotionGeneralSection extends StatelessWidget {
  /// Creates Medusa's promotion General card.
  const AdminPromotionGeneralSection({
    required this.promotion,
    super.key,
  });

  /// Explicit promotion detail.
  final AdminPromotion promotion;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shadowColor: const Color(0x16000000),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(children: [
              Expanded(
                child: Text(
                  promotion.code,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _AdminPromotionStatusText(status: promotion.status),
            ]),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _AdminPromotionField(label: 'Method', value: _method),
          _AdminPromotionField(label: 'Type', value: promotion.type),
          _AdminPromotionField(label: 'Value', value: _value),
          _AdminPromotionField(label: 'Usage', value: _usage),
          _AdminPromotionField(
              label: 'Created', value: _date(promotion.createdAt)),
          _AdminPromotionField(
              label: 'Updated', value: _date(promotion.updatedAt)),
        ]),
      );

  String get _method => promotion.isAutomatic ? 'Automatic' : 'Code';

  String get _usage => switch (promotion.usageLimit) {
        Some(:final value) => '${promotion.usageCount} / $value',
        None() => '${promotion.usageCount}',
      };

  String get _value => switch (promotion.currencyCode) {
        Some(:final value) => '${promotion.value} ${value.toUpperCase()}',
        None() => '${promotion.value / 100}%',
      };

  String _date(DateTime value) => DateFormat.yMMMd().add_jm().format(
        value.toLocal(),
      );
}

final class _AdminPromotionField extends StatelessWidget {
  const _AdminPromotionField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(value),
        ]),
      );
}

final class _AdminPromotionStatusText extends StatelessWidget {
  const _AdminPromotionStatusText({required this.status});

  final AdminPromotionStatus status;

  @override
  Widget build(BuildContext context) => Text(
        switch (status) {
          AdminPromotionStatus.active => 'Active',
          AdminPromotionStatus.scheduled => 'Scheduled',
          AdminPromotionStatus.expired => 'Expired',
        },
        style: Theme.of(context).textTheme.labelMedium,
      );
}
