import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/widgets.dart';

import 'store_footer_link.dart';

/// Creates the source Customer service footer links.
List<Widget> customerServiceFooterLinks(BuildContext context) => [
      FooterTextLink(
        label: 'Shipping information',
        onPressed: () => context.navigator.shipping().go(),
      ),
      FooterTextLink(
        label: 'Return policy',
        onPressed: () => context.navigator.returns().go(),
      ),
      FooterTextLink(
        label: 'Terms of service',
        onPressed: () => context.navigator.terms().go(),
      ),
      FooterTextLink(
        label: 'Privacy policy',
        onPressed: () => context.navigator.privacy().go(),
      ),
      FooterTextLink(
        label: 'Contact',
        onPressed: () => context.navigator.contact().go(),
      ),
    ];

/// Creates the Dust attribution links without coupling URL launching to UI.
List<Widget> dustFooterLinks(
  BuildContext context,
  void Function(String location) open,
) =>
    [
      FooterTextLink(
        label: 'GitHub',
        onPressed: () => open('https://github.com/dustcodegen/dust'),
      ),
      FooterTextLink(
        label: context.tr(
          'shop_footer_documentation',
          defaultText: 'Documentation',
        ),
        onPressed: () => open(
          'https://github.com/dustcodegen/dust/tree/main/docs',
        ),
      ),
      FooterTextLink(
        label: context.tr(
          'shop_footer_source_code',
          defaultText: 'Source code',
        ),
        onPressed: () => open('https://github.com/dustcodegen/dust-commerce'),
      ),
    ];
