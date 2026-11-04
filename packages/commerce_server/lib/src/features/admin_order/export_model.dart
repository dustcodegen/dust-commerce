import 'package:dust_dart/db.dart';

part 'export_model.g.dart';

/// Direct database projection for one order and optional frozen item export row.
@Derive([FromRow()])
@Sqlx(renameAll: SqlxRename.snakeCase)
final class AdminOrderExportRow {
  /// Creates the private merchant CSV projection.
  const AdminOrderExportRow({
    required this.orderId,
    required this.displayId,
    required this.status,
    required this.paymentStatus,
    required this.fulfillmentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.email,
    required this.customerName,
    required this.currencyCode,
    required this.subtotal,
    required this.shippingTotal,
    required this.discountTotal,
    required this.taxTotal,
    required this.total,
    required this.shippingName,
    required this.promotionCode,
    required this.itemId,
    required this.itemTitle,
    required this.itemVariantTitle,
    required this.itemQuantity,
    required this.itemUnitAmount,
    required this.shippingRecipient,
    required this.shippingCompany,
    required this.shippingLine1,
    required this.shippingLine2,
    required this.shippingCity,
    required this.shippingProvince,
    required this.shippingPostalCode,
    required this.shippingCountryCode,
    required this.shippingPhone,
    required this.billingRecipient,
    required this.billingCompany,
    required this.billingLine1,
    required this.billingLine2,
    required this.billingCity,
    required this.billingProvince,
    required this.billingPostalCode,
    required this.billingCountryCode,
    required this.billingPhone,
    required this.paymentProvider,
    required this.paymentAmount,
    required this.paymentRecordStatus,
    required this.paymentCapturedAt,
  });

  /// Required order identity, lifecycle, timestamps and customer values.
  // Grouped because these values share the same required text representation.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String orderId, status, paymentStatus, fulfillmentStatus;
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final DateTime createdAt, updatedAt;
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String email, customerName, currencyCode;

  /// Required order totals represented in exact minor units.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final int displayId, subtotal, shippingTotal, discountTotal, taxTotal, total;

  /// Optional order-level delivery and promotion labels.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? shippingName, promotionCode;

  /// Optional frozen line identity and display values.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? itemId, itemTitle, itemVariantTitle;

  /// Optional frozen line quantity and unit amount.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final int? itemQuantity, itemUnitAmount;

  /// Optional frozen shipping destination values.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? shippingRecipient, shippingCompany, shippingLine1;
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? shippingLine2, shippingCity, shippingProvince;
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? shippingPostalCode, shippingCountryCode, shippingPhone;

  /// Optional frozen billing destination values.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? billingRecipient, billingCompany, billingLine1;
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? billingLine2, billingCity, billingProvince;
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? billingPostalCode, billingCountryCode, billingPhone;

  /// Optional provider payment record values.
  // ignore: public_member_api_docs, avoid_multiple_declarations_per_line
  final String? paymentProvider, paymentRecordStatus;

  /// Optional provider capture instant.
  final DateTime? paymentCapturedAt;

  /// Optional provider payment amount in exact minor units.
  final int? paymentAmount;
}
