import 'dart:convert';

import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the latest completed guest receipt available after a browser reload.
abstract interface class OrderReceiptStore {
  /// Reads [orderId] only when it is the receipt saved on this device.
  Future<Order?> read(String orderId);

  /// Replaces the locally retained receipt with [order].
  Future<void> write(Order order);
}

/// Encrypted-at-rest receipt persistence for the production application.
final class SecureOrderReceiptStore implements OrderReceiptStore {
  /// Creates a receipt store over the platform secure storage.
  SecureOrderReceiptStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(migrateWithBackup: true),
            );

  final FlutterSecureStorage _storage;

  static const _idKey = 'morrow.order.latest.id.v1';
  static const _receiptKey = 'morrow.order.latest.receipt.v1';

  @override
  Future<Order?> read(String orderId) async {
    if (await _storage.read(key: _idKey) != orderId) return null;
    final encoded = await _storage.read(key: _receiptKey);
    if (encoded == null) return null;
    try {
      return Order.fromJson(jsonDecode(encoded) as Map<String, Object?>);
    } on Object {
      // Local receipt corruption must not break the confirmation route.
      return null;
    }
  }

  @override
  Future<void> write(Order order) async {
    await _storage.write(key: _receiptKey, value: jsonEncode(order));
    await _storage.write(key: _idKey, value: order.id);
  }
}
