import 'package:commerce_server/src/features/customer_service/model.dart';
import 'package:dust_dart/db.dart';

part 'repository.g.dart';

/// Direct SQLx persistence for public customer-service submissions.
@SqlxDao()
abstract final class CustomerServiceRepository {
  /// Binds request creation to [db].
  const factory CustomerServiceRepository(Executor db) =
      _$CustomerServiceRepository;

  /// Persists one bounded message and returns only Store-safe fields.
  @Query(r'''
INSERT INTO customer_service_requests
  (id, customer_id, name, email, subject, message, order_reference)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING id, created_at
''')
  Future<Result<CustomerServiceSubmissionResponse, SqlxError>> create(
    String id,
    String? customerId,
    String name,
    String email,
    String subject,
    String message,
    String? orderReference,
  );
}
