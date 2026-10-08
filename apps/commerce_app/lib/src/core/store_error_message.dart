import 'package:flutter/material.dart';

import 'store_theme.dart';

/// Source-shaped storefront failure copy from Medusa ErrorMessage.
final class StoreErrorMessage extends StatelessWidget {
  /// Creates an inline storefront error message.
  const StoreErrorMessage(this.message, {super.key});

  /// Customer-facing error returned by the active operation.
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(message, style: _storeErrorStyle),
      );
}

const _storeErrorStyle = TextStyle(
  color: StoreColors.rose,
  fontSize: 12,
  height: 20 / 12,
);
