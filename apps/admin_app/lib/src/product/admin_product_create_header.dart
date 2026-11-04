part of 'admin_product_create_page.dart';

final class _CreateHeader extends StatelessWidget {
  const _CreateHeader({
    required this.step,
    required this.saving,
    required this.onStep,
    required this.onClose,
  });

  final VoidCallback? onClose;
  final ValueChanged<int> onStep;
  final bool saving;
  final int step;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Close',
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'esc',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).dividerColor,
            ),
            for (var index = 0; index < 3; index++)
              Expanded(
                child: InkWell(
                  onTap: saving ? null : () => onStep(index),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right:
                            BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < step
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: index <= step
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          child: index < step
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 11,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                )
                              : index == step
                                  ? Center(
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    )
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            const ['Details', 'Organize', 'Variants'][index],
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: step == index
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
