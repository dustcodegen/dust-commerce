import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Account help footer from the source layout.
class AccountSupport extends StatelessWidget {
  /// Creates the help footer.
  const AccountSupport({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1024;
    final questions = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TranslatedText(
          'shop_account_questions',
          defaultText: 'Got questions?',
          style: TextStyle(
            fontSize: 24,
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.tr(
            'shop_account_questions_body',
            defaultText: 'You can find frequently asked questions and '
                'answers on our customer service page.',
          ),
          style: const TextStyle(fontSize: 14, height: 20 / 14),
        ),
      ],
    );
    final customerService = StoreInteractiveLink(
      onPressed: () => context.navigator.customerService().go(),
      child: const TranslatedText(
        'shop_account_customer_service',
        defaultText: 'Customer Service',
      ),
    );

    if (desktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: questions),
          const SizedBox(width: 24),
          customerService,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: double.infinity, child: questions),
        const SizedBox(height: 32),
        customerService,
      ],
    );
  }
}
