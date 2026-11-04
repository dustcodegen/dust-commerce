import 'package:commerce_server/src/features/customer_service/model.dart';
import 'package:commerce_server/src/features/customer_service/repository.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Persists one validated support request without creating a fake reply.
Future<Result<CustomerServiceSubmissionResponse, SqlxError>>
    createCustomerServiceRequest(
  CustomerServiceRepository requests,
  CustomerServiceRequestBody input, {
  required String id,
  required String? customerId,
}) =>
        requests.create(
          id,
          customerId,
          input.name,
          input.email,
          input.subject,
          input.message,
          switch (input.orderReference) {
            Some(:final value) => value,
            None() => null,
          },
        );
