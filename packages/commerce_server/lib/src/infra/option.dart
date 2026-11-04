import 'package:dust_dart/fp.dart';

/// Converts the nullable value required by Dust SQLx optional-row terminals.
///
/// Generated DAOs use `T?` because `fetchOptional` is their runtime contract.
/// The conversion happens once at that persistence boundary; services expose
/// explicit [Option] values instead of propagating nullable entity results.
Option<T> optionOf<T extends Object>(T? value) => switch (value) {
      final present? => Some<T>(present),
      null => None<T>(),
    };

/// Converts an explicit optional value only at a nullable persistence boundary.
T? nullableOf<T extends Object>(Option<T> value) => switch (value) {
      Some(value: final present) => present,
      None() => null,
    };
