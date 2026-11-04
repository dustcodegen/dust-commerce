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

/// Formats a payment instant like Medusa's Date.toLocaleString().
String formatStoreDateTime(
  MaterialLocalizations _,
  DateTime value,
) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '${local.month}/${local.day}/${local.year}, '
      '$hour:${_twoDigits(local.minute)}:${_twoDigits(local.second)} $period';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
