part of 'admin_product_filter_bar.dart';

const _addFilterItemStyle = ButtonStyle(
  minimumSize: WidgetStatePropertyAll(Size(292, 32)),
  maximumSize: WidgetStatePropertyAll(Size(292, 32)),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.standard,
);

MenuStyle _filterMenuStyle(BuildContext context) => MenuStyle(
      backgroundColor:
          WidgetStatePropertyAll(Theme.of(context).colorScheme.surface),
      minimumSize: const WidgetStatePropertyAll(Size(300, 0)),
      maximumSize: const WidgetStatePropertyAll(Size(300, 200)),
      padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
    );
