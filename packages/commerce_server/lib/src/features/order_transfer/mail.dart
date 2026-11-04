/// Message handed to the configured order-transfer delivery adapter.
final class OrderTransferMail {
  /// Creates one owner-decision email.
  const OrderTransferMail({
    required this.recipient,
    required this.orderId,
    required this.token,
    required this.expiresAt,
  });

  /// UTC deadline after which the capability is rejected.
  final DateTime expiresAt;

  /// Order named in the message and transfer route.
  final String orderId;

  /// Existing order contact authorized to accept or decline.
  final String recipient;

  /// Raw capability used only to build the decision link.
  final String token;
}

/// Delivers the capability to the order's existing contact address.
abstract interface class OrderTransferMailer {
  /// Whether delivery is configured for this server process.
  bool get isAvailable;

  /// Sends one transfer decision message.
  Future<void> send(OrderTransferMail mail);
}

/// Honest default for servers without outbound email configuration.
final class UnavailableOrderTransferMailer implements OrderTransferMailer {
  /// Creates the disabled adapter.
  const UnavailableOrderTransferMailer();

  @override
  bool get isAvailable => false;

  @override
  Future<void> send(OrderTransferMail mail) =>
      throw const OrderTransferMailUnavailable();
}

/// Signals that no outbound mail transport was configured.
final class OrderTransferMailUnavailable implements Exception {
  /// Creates the configuration failure signal.
  const OrderTransferMailUnavailable();
}
