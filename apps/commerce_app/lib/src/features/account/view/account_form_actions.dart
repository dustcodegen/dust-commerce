part of 'account_auth_form.dart';

class _AccountFormActions extends StatelessWidget {
  const _AccountFormActions({
    required this.registering,
    required this.busy,
    required this.onSubmit,
    required this.onToggle,
    this.error,
  });

  final bool registering;
  final bool busy;
  final String? error;
  final VoidCallback onSubmit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error case final message?) ...[
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          if (registering) ...[
            const SizedBox(height: 24),
            Text(
              context.tr(
                'shop_account_terms',
                defaultText: "By creating an account, you agree to Morrow's "
                    'Privacy Policy and Terms of Use.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: StoreColors.foregroundSubtle,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: busy ? null : onSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.standard,
            ),
            child: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: StoreColors.base,
                    ),
                  )
                : Text(
                    registering
                        ? context.tr(
                            'shop_account_join',
                            defaultText: 'Join',
                          )
                        : context.tr(
                            'shop_account_sign_in',
                            defaultText: 'Sign in',
                          ),
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                registering
                    ? context.tr(
                        'shop_account_already_member',
                        defaultText: 'Already a member?',
                      )
                    : context.tr(
                        'shop_account_not_member',
                        defaultText: 'Not a member?',
                      ),
                style: const TextStyle(fontSize: 12),
              ),
              TextButton(
                onPressed: busy ? null : onToggle,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: Text(
                  registering
                      ? context.tr(
                          'shop_account_sign_in',
                          defaultText: 'Sign in',
                        )
                      : context.tr(
                          'shop_account_join_us',
                          defaultText: 'Join us',
                        ),
                ),
              ),
              Text(
                context.tr(
                  'shop_account_sentence_end',
                  defaultText: '.',
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      );
}
