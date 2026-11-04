import 'package:dust_dart/serde.dart';

part 'customer_service.g.dart';

/// Public Store input for one customer-service request.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CustomerServiceRequestBody with _$CustomerServiceRequestBody {
  /// Creates one bounded support message.
  const CustomerServiceRequestBody({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    this.orderReferenceValue,
  });

  /// Decodes JSON using generated normalization codecs.
  factory CustomerServiceRequestBody.fromJson(Map<String, Object?> json) =>
      _$CustomerServiceRequestBodyFromJson(json);

  /// Reply address normalized for delivery and Admin search.
  @SerDe(using: _CustomerServiceEmailCodec())
  @Validate(length: Length(min: 3, max: 254), message: 'Enter a valid email')
  @Validate(email: true, message: 'Enter a valid email')
  final String email;

  /// Customer-authored support detail.
  @SerDe(using: _CustomerServiceTextCodec())
  @Validate(length: Length(min: 1, max: 5000), message: 'Enter a message')
  @Validate(regex: r'.*\S.*', message: 'Enter a message')
  final String message;

  /// Name used by the support team when replying.
  @SerDe(using: _CustomerServiceTextCodec())
  @Validate(length: Length(min: 1, max: 120), message: 'Enter your name')
  @Validate(regex: r'.*\S.*', message: 'Enter your name')
  final String name;

  /// Explicit absence when the shopper has no order reference.
  Option<String> get orderReference => switch (orderReferenceValue) {
        final String value when value.trim().isNotEmpty => Some(value.trim()),
        _ => const None(),
      };

  /// Nullable wire backing for [orderReference].
  @SerDe(rename: 'order_reference')
  @Validate(length: Length(max: 255), message: 'Use at most 255 characters')
  final String? orderReferenceValue;

  /// Short routing context shown in the Admin inbox.
  @SerDe(using: _CustomerServiceTextCodec())
  @Validate(length: Length(min: 1, max: 160), message: 'Enter a subject')
  @Validate(regex: r'.*\S.*', message: 'Enter a subject')
  final String subject;
}

/// Minimal acknowledgement returned after durable persistence.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CustomerServiceSubmission with _$CustomerServiceSubmission {
  /// Creates a customer-safe acknowledgement.
  const CustomerServiceSubmission({required this.id, required this.createdAt});

  /// Decodes one generated Store response.
  factory CustomerServiceSubmission.fromJson(Map<String, Object?> json) =>
      _$CustomerServiceSubmissionFromJson(json);

  /// Database-generated submission instant.
  final DateTime createdAt;

  /// Stable request identifier used when contacting support again.
  final String id;
}

final class _CustomerServiceEmailCodec implements SerDeCodec<String, String> {
  const _CustomerServiceEmailCodec();

  @override
  String deserialize(String value) => value.trim().toLowerCase();

  @override
  String serialize(String value) => value.trim().toLowerCase();
}

final class _CustomerServiceTextCodec implements SerDeCodec<String, String> {
  const _CustomerServiceTextCodec();

  @override
  String deserialize(String value) => value.trim();

  @override
  String serialize(String value) => value.trim();
}
