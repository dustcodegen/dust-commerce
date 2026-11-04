import 'package:admin_app/src/core/admin_date_filter_preset.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 15, 14, 30);

  test('Medusa date presets use local calendar boundaries', () {
    expect(
      adminDateFilterFromPreset(AdminDateFilterPreset.today, now),
      AdminDateFilter(greaterThanOrEqual: Some(DateTime(2026, 9, 15))),
    );
    expect(
      adminDateFilterFromPreset(AdminDateFilterPreset.lastSevenDays, now),
      AdminDateFilter(greaterThanOrEqual: Some(DateTime(2026, 9, 8))),
    );
    expect(
      adminDateFilterFromPreset(AdminDateFilterPreset.lastTwelveMonths, now),
      AdminDateFilter(greaterThanOrEqual: Some(DateTime(2025, 9, 15))),
    );
  });

  test('labels exact presets and custom inclusive ranges', () {
    final preset = adminDateFilterFromPreset(
      AdminDateFilterPreset.lastThirtyDays,
      now,
    );
    final custom = AdminDateFilter(
      greaterThanOrEqual: Some(DateTime(2026, 8, 1)),
      lessThanOrEqual: Some(DateTime(2026, 8, 31, 23, 59, 59)),
    );

    expect(adminDateFilterLabel(preset, now), 'Last 30 days');
    expect(adminDateFilterLabel(custom, now), 'Aug 1, 2026 - Aug 31, 2026');
  });

  test('custom end includes the final local millisecond', () {
    expect(
      adminDateFilterEndOfDay(DateTime(2026, 9, 15)),
      DateTime(2026, 9, 15, 23, 59, 59, 999, 999),
    );
  });
}
