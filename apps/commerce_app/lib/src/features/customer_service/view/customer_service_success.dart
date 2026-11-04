import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Durable submission acknowledgement shown as a live region.
final class CustomerServiceSuccess extends StatelessWidget {
  /// Creates success feedback for [submission].
  const CustomerServiceSuccess({
    required this.submission,
    required this.onAnother,
    super.key,
  });

  /// Starts another clean form while keeping contact identity.
  final VoidCallback onAnother;

  /// Minimal server acknowledgement.
  final CustomerServiceSubmission submission;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: StoreColors.neutral50,
            border: Border.all(color: StoreColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: StoreColors.success,
                size: 24,
              ),
              const SizedBox(height: 16),
              const TranslatedText(
                'shop_customer_service_received',
                defaultText: 'Message received',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(context.tr(
                'shop_customer_service_reference',
                defaultText: 'Keep this reference: {id}',
                args: {'id': submission.id},
              )),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onAnother,
                child: const TranslatedText(
                  'shop_customer_service_send_another',
                  defaultText: 'Send another message',
                ),
              ),
            ],
          ),
        ),
      );
}
