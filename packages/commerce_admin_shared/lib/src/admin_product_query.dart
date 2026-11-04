import 'dart:convert';

import 'package:dust_dart/derive.dart';

part 'admin_product_query.g.dart';

/// One Medusa-compatible timestamp comparison carried in a query parameter.
@Derive([ToString(), Eq()])
final class AdminDateFilter with _$AdminDateFilter {
  /// Creates an immutable comparison without nullable boundary values.
  const AdminDateFilter({
    this.greaterThan = const None(),
    this.greaterThanOrEqual = const None(),
    this.lessThan = const None(),
    this.lessThanOrEqual = const None(),
  });

  /// Exclusive lower bound.
  final Option<DateTime> greaterThan;

  /// Inclusive lower bound used by the Admin date picker.
  final Option<DateTime> greaterThanOrEqual;

  /// Exclusive upper bound.
  final Option<DateTime> lessThan;

  /// Inclusive upper bound used by the Admin date picker.
  final Option<DateTime> lessThanOrEqual;

  /// Whether this value applies no timestamp constraint.
  bool get isEmpty =>
      greaterThan is None<DateTime> &&
      greaterThanOrEqual is None<DateTime> &&
      lessThan is None<DateTime> &&
      lessThanOrEqual is None<DateTime>;

  /// JSON value expected by Medusa's `created_at` and `updated_at` params.
  String get parameter => jsonEncode({
        if (greaterThan case Some(:final value))
          r'$gt': value.toUtc().toIso8601String(),
        if (greaterThanOrEqual case Some(:final value))
          r'$gte': value.toUtc().toIso8601String(),
        if (lessThan case Some(:final value))
          r'$lt': value.toUtc().toIso8601String(),
        if (lessThanOrEqual case Some(:final value))
          r'$lte': value.toUtc().toIso8601String(),
      });

  /// Parses and normalizes one untrusted Medusa timestamp comparison.
  static Option<AdminDateFilter> parse(String parameter) {
    if (parameter.isEmpty) return const Some(AdminDateFilter());
    try {
      final value = jsonDecode(parameter);
      if (value is! Map<String, Object?>) return const None();
      const allowed = {r'$gt', r'$gte', r'$lt', r'$lte'};
      if (value.keys.any((key) => !allowed.contains(key))) return const None();
      final parsed = <String, DateTime>{};
      for (final entry in value.entries) {
        final instant = _parseInstant(entry.value);
        if (instant case None()) return const None();
        parsed[entry.key] = (instant as Some<DateTime>).value;
      }
      final filter = AdminDateFilter(
        greaterThan: _option(parsed[r'$gt']),
        greaterThanOrEqual: _option(parsed[r'$gte']),
        lessThan: _option(parsed[r'$lt']),
        lessThanOrEqual: _option(parsed[r'$lte']),
      );
      return filter._boundsAreOrdered ? Some(filter) : const None();
    } on FormatException {
      return const None();
    }
  }

  bool get _boundsAreOrdered {
    final lowers = [greaterThan, greaterThanOrEqual];
    final uppers = [lessThan, lessThanOrEqual];
    for (final lower in lowers) {
      for (final upper in uppers) {
        if (lower case Some(value: final start)) {
          if (upper case Some(value: final end)) {
            if (start.isAfter(end)) return false;
          }
        }
      }
    }
    return true;
  }
}

Option<DateTime> _option(DateTime? value) => switch (value) {
      final DateTime instant => Some(instant),
      null => const None(),
    };

Option<DateTime> _parseInstant(Object? value) {
  if (value is! String || !RegExp(r'(?:Z|[+-]\d{2}:\d{2})$').hasMatch(value)) {
    return const None();
  }
  final parsed = DateTime.tryParse(value);
  return parsed == null ? const None() : Some(parsed.toUtc());
}

/// Product-list order values accepted by the Medusa-shaped Admin API.
enum AdminProductOrder {
  /// Product title A to Z.
  titleAsc('title'),

  /// Product title Z to A.
  titleDesc('-title'),

  /// Oldest products first.
  createdAtAsc('created_at'),

  /// Newest products first.
  createdAtDesc('-created_at'),

  /// Least recently updated products first.
  updatedAtAsc('updated_at'),

  /// Most recently updated products first.
  updatedAtDesc('-updated_at');

  const AdminProductOrder(this.parameter);

  /// Stable Admin API query value.
  final String parameter;

  /// Parses one allowlisted Admin API query value.
  static Option<AdminProductOrder> parse(String parameter) {
    for (final order in values) {
      if (order.parameter == parameter) return Some(order);
    }
    return const None();
  }
}
