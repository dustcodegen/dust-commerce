import 'package:flutter/material.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a customer-facing order date like Medusa's Date.toDateString().
String formatStoreDate(
  MaterialLocalizations _,
  DateTime value,
) {
  final local = value.toLocal();
  return '${_weekdays[local.weekday - 1]} '
      '${_months[local.month - 1]} ${local.day} ${local.year}';
}

/// Formats a customer-facing order instant without dropping its year.
String formatStoreDateTime(
  MaterialLocalizations localizations,
  DateTime value,
) {
  final local = value.toLocal();
  return '${formatStoreDate(localizations, local)}, '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
}
