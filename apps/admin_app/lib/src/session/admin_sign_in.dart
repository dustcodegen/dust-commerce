import 'package:admin_app/src/session/admin_session_state.dart';
import 'package:admin_app/src/session/admin_session_view_model.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped email/password entry for the isolated merchant actor.
final class AdminSignIn extends StatefulWidget {
  /// Creates the sign-in screen.
  const AdminSignIn({required this.state, super.key});

  /// Current authentication request state.
  final AdminSessionState state;

  @override
  State<AdminSignIn> createState() => _AdminSignInState();
}

final class _AdminSignInState extends State<AdminSignIn> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _MorrowMark(),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access Morrow Admin',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _email,
                      autofillHints: const [AutofillHints.username],
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      autofillHints: const [AutofillHints.password],
                      obscureText: true,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(hintText: 'Password'),
                    ),
                    if (widget.state.failure case Some(value: final message))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: widget.state.isBusy ? null : _submit,
                      child: const Text('Continue'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Powered by dust',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  void _submit() {
    FocusScope.of(context).unfocus();
    context.readAdminSessionViewModel().signIn(_email.text, _password.text);
  }
}

final class _MorrowMark extends StatelessWidget {
  const _MorrowMark();

  @override
  Widget build(BuildContext context) => Align(
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(9),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 2),
            ],
          ),
          child: const Text('M', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
}
