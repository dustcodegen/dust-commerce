import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const localizations = DefaultMaterialLocalizations();

  test('customer order dates retain the calendar year', () {
    final date = DateTime(2026, 9, 15, 14, 30);

    expect(formatStoreDate(localizations, date), 'Tue Sep 15 2026');
  });

  test('customer payment dates retain year and time', () {
    final date = DateTime(2026, 9, 15, 14, 30);

    expect(
      formatStoreDateTime(localizations, date),
      'Tue Sep 15 2026, 2:30 PM',
    );
  });
}
