import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/core/admin_session_store.dart';
import 'package:admin_app/src/session/admin_session_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_session_view_model.g.dart';

/// Dependencies for admin session state.
final class AdminSessionViewModelArgs extends ViewModelArgs {
  /// Creates admin session dependencies.
  const AdminSessionViewModelArgs({
    required this.api,
    required this.sessions,
    DateTime Function()? now,
    super.observer,
  }) : now = now ?? DateTime.now;

  /// Generated admin-only API client.
  final AdminApi api;

  /// Clock used only for token-expiry decisions.
  final DateTime Function() now;

  /// Admin-only secure bearer persistence.
  final AdminSessionStore sessions;
}

/// Restores, creates, and revokes the isolated merchant session.
@ViewModel(state: AdminSessionState, args: AdminSessionViewModelArgs)
final class AdminSessionViewModel extends $AdminSessionViewModel {
  /// Creates the session state machine.
  AdminSessionViewModel(super.args);

  @override
  Future<void> onInit() => restore();

  /// Verifies a usable stored bearer against the server.
  Future<void> restore() async {
    emit(const AdminSessionState(status: AdminSessionStatus.loading));
    try {
      final stored = await args.sessions.read();
      switch (stored) {
        case Some(value: final session) when !session.isExpiredAt(args.now()):
          final user = await args.api.currentUser();
          emit(AdminSessionState(
            status: AdminSessionStatus.signedIn,
            user: Some(user),
          ));
        case Some():
          await args.sessions.clear();
          emit(const AdminSessionState(status: AdminSessionStatus.signedOut));
        case None():
          emit(const AdminSessionState(status: AdminSessionStatus.signedOut));
      }
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await args.sessions.clear();
        emit(const AdminSessionState(status: AdminSessionStatus.signedOut));
        return;
      }
      _fail('Unable to reach the admin service.');
    } on Object {
      _fail('Unable to restore the admin session.');
    }
  }

  /// Exchanges credentials for a server-verified admin session.
  Future<bool> signIn(String email, String password) async {
    if (state.isBusy) return false;
    emit(const AdminSessionState(status: AdminSessionStatus.loading));
    try {
      final token = await args.api.signIn(
        AdminCredentials(email: email, password: password),
      );
      await args.sessions.write(token);
      final user = await args.api.currentUser();
      emit(AdminSessionState(
        status: AdminSessionStatus.signedIn,
        user: Some(user),
      ));
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        _fail('Invalid email or password.');
      } else {
        _fail('Unable to sign in. Try again.');
      }
      return false;
    } on Object {
      _fail('Unable to sign in. Try again.');
      return false;
    }
  }

  /// Revokes the server bearer, then clears local secure storage.
  Future<void> signOut() async {
    if (state.isBusy) return;
    final current = state.user;
    emit(AdminSessionState(
      status: AdminSessionStatus.loading,
      user: current,
    ));
    try {
      await args.api.signOut();
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) {
        _fail('Unable to sign out. Try again.', user: current);
        return;
      }
    } on Object {
      _fail('Unable to sign out. Try again.', user: current);
      return;
    }
    await args.sessions.clear();
    emit(const AdminSessionState(status: AdminSessionStatus.signedOut));
  }

  void _fail(String message, {Option<AdminUser> user = const None()}) {
    emit(AdminSessionState(
      status: AdminSessionStatus.failed,
      user: user,
      failure: Some(message),
    ));
  }
}
