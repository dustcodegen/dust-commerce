import 'package:dust_dart/fp.dart';

/// Converts a nullable JSON backing value into explicit application absence.
Option<T> adminOptionOf<T>(T? value) => switch (value) {
      null => const None(),
      final T value => Some(value),
    };
