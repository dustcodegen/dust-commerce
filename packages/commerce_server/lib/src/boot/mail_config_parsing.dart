part of 'order_transfer_mail_config.dart';

String _required(Map<String, String> source, String key) {
  final value = source[key]?.trim();
  if (value == null || value.isEmpty) {
    throw FormatException('$key is required when SMTP email is configured.');
  }
  return _withoutControlCharacters(value, key);
}

Option<String> _optional(Map<String, String> source, String key) {
  final value = source[key]?.trim();
  return value == null || value.isEmpty
      ? const None()
      : Some(_withoutControlCharacters(value, key));
}

Option<String> _optionalRaw(Map<String, String> source, String key) {
  final value = source[key];
  return value == null || value.isEmpty ? const None() : Some(value);
}

int _integer(
  Map<String, String> source,
  String key,
  int fallback,
  int minimum,
  int maximum,
) {
  final text = source[key];
  final value = text == null ? fallback : int.tryParse(text);
  if (value == null || value < minimum || value > maximum) {
    throw FormatException('$key must be between $minimum and $maximum.');
  }
  return value;
}

bool _boolean(Map<String, String> source, String key, bool fallback) {
  return switch (source[key]) {
    null => fallback,
    'true' => true,
    'false' => false,
    _ => throw FormatException('$key must be true or false.'),
  };
}

String _withoutControlCharacters(String value, String key) {
  if (value.contains(RegExp(r'[\x00-\x1F\x7F]'))) {
    throw FormatException('$key must not contain control characters.');
  }
  return value;
}
