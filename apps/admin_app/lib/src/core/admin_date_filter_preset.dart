import 'dart:math';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Relative choices exposed by Medusa's Admin date filters.
enum AdminDateFilterPreset {
  /// Current local calendar day.
  today('Today'),

  /// Current day and the preceding seven days.
  lastSevenDays('Last 7 days'),

  /// Current day and the preceding thirty days.
  lastThirtyDays('Last 30 days'),

  /// Current day and the preceding ninety days.
  lastNinetyDays('Last 90 days'),

  /// Current day and the preceding twelve calendar months.
  lastTwelveMonths('Last 12 months');

  const AdminDateFilterPreset(this.label);

  /// Merchant-facing Medusa label.
  final String label;
}

/// Builds one inclusive lower bound from a local calendar preset.
AdminDateFilter adminDateFilterFromPreset(
  AdminDateFilterPreset preset,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final start = switch (preset) {
    AdminDateFilterPreset.today => today,
    AdminDateFilterPreset.lastSevenDays =>
      today.subtract(const Duration(days: 7)),
    AdminDateFilterPreset.lastThirtyDays =>
      today.subtract(const Duration(days: 30)),
    AdminDateFilterPreset.lastNinetyDays =>
      today.subtract(const Duration(days: 90)),
    AdminDateFilterPreset.lastTwelveMonths => _monthsAgo(today, 12),
  };
  return AdminDateFilter(greaterThanOrEqual: Some(start));
}

/// Formats a preset label when exact, otherwise its visible custom range.
String adminDateFilterLabel(AdminDateFilter value, DateTime now) {
  for (final preset in AdminDateFilterPreset.values) {
    if (value == adminDateFilterFromPreset(preset, now)) return preset.label;
  }
  final format = DateFormat.yMMMd();
  final start = switch (value.greaterThanOrEqual) {
    Some(value: final date) => format.format(date.toLocal()),
    None() => '',
  };
  final end = switch (value.lessThanOrEqual) {
    Some(value: final date) => format.format(date.toLocal()),
    None() => '',
  };
  if (start.isNotEmpty && end.isNotEmpty) return '$start - $end';
  if (start.isNotEmpty) return 'Starting $start';
  if (end.isNotEmpty) return 'Ending $end';
  return 'Custom';
}

/// Selectable initial range for Medusa's custom date option.
DateTimeRange adminDateFilterInitialRange(
  AdminDateFilter value,
  DateTime now,
) {
  final fallback = DateTime(now.year, now.month, now.day);
  final start = switch (value.greaterThanOrEqual) {
    Some(value: final date) => date.toLocal(),
    None() => fallback,
  };
  final end = switch (value.lessThanOrEqual) {
    Some(value: final date) => date.toLocal(),
    None() => fallback,
  };
  return DateTimeRange(start: start, end: end);
}

/// Includes the entire selected local end date.
DateTime adminDateFilterEndOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day, 23, 59, 59, 999, 999);

DateTime _monthsAgo(DateTime value, int months) {
  final index = value.year * 12 + value.month - 1 - months;
  final year = index ~/ 12;
  final month = index % 12 + 1;
  final day = min(value.day, DateTime(year, month + 1, 0).day);
  return DateTime(year, month, day);
}
