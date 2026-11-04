import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/customer_service/deps.dart';
import 'package:commerce_server/src/features/customer_service/model.dart';
import 'package:commerce_server/src/features/customer_service/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<CustomerServiceRequestBody> _body =
    ValidatedExtractable(
  StrictJsonExtractable<CustomerServiceRequestBody>(
    CustomerServiceRequestBody.fromJson,
    fields: {'name', 'email', 'subject', 'message', 'order_reference'},
  ),
);

/// `POST /store/customer-service` — persists one guest-compatible request.
Future<Result<CustomerServiceSubmissionResponse, Rejection>>
    createCustomerServiceHandler(Request request) async {
  final context = await request.extract(const Extension<CustomerContext>());
  final decoded = await _body.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await customerServiceDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CustomerServiceDeps, Rejection>).value;
  final input = (decoded as Ok<CustomerServiceRequestBody, Rejection>).value;
  final customerId = context.authenticated.match(
    some: (value) => value.customer.id,
    none: () => null,
  );
  final result = await createCustomerServiceRequest(
    deps.requests,
    input,
    id: deps.nextId(),
    customerId: customerId,
  );

  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
