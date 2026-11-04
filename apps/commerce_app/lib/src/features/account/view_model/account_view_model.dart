import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/core/storage/storage.dart';
import 'package:commerce_app/src/features/account/model/account_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'account_view_model.g.dart';
part 'account_authentication.dart';
part 'account_error.dart';
part 'account_password.dart';
part 'account_profile.dart';

/// Dependencies for customer account and session state.
final class AccountViewModelArgs extends ViewModelArgs {
  /// Creates account dependencies.
  const AccountViewModelArgs({
    required this.api,
    required this.sessions,
    DateTime Function()? now,
    super.observer,
  }) : now = now ?? DateTime.now;

  /// Generated storefront client.
  final CommerceApi api;

  /// Secure bearer-session persistence.
  final AuthSessionStore sessions;

  /// Clock used for deterministic expiry decisions.
  final DateTime Function() now;
}

/// Owns registration, sign-in, verified restore, and sign-out.
@ViewModel(state: AccountState, args: AccountViewModelArgs)
class AccountViewModel extends $AccountViewModel
    with
        _AccountAuthentication,
        _AccountProfileMutation,
        _AccountPasswordMutation {
  /// Creates the account view model.
  AccountViewModel(super.args);

  Future<void>? _restoreTask;
  bool _isRestoring = false;

  /// Whether persisted credentials are currently being verified.
  bool get isRestoring => _isRestoring;

  @override
  Future<void> onInit() => restore();

  /// Restores a valid persisted session and verifies it with the server.
  Future<void> restore({bool force = false}) {
    final active = _restoreTask;
    if (active != null) return active;
    if (!force && state.isAuthenticated) return Future<void>.value();
    _isRestoring = true;
    final task = _restore();
    _restoreTask = task;
    return task.whenComplete(() {
      _restoreTask = null;
      _isRestoring = false;
    });
  }

  Future<void> _restore() async {
    emit(const AccountState(
      status: AccountStatus.loading,
      operation: AccountOperation.restore,
    ));
    try {
      final session = await args.sessions.read();
      if (session == null) {
        emit(const AccountState(status: AccountStatus.signedOut));
        return;
      }
      if (session.isExpiredAt(args.now())) {
        await args.sessions.clear();
        emit(const AccountState(status: AccountStatus.signedOut));
        return;
      }
      final customer = await args.api.currentCustomer();
      emit(AccountState(
        status: AccountStatus.signedIn,
        customer: customer,
      ));
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await args.sessions.clear();
        emit(const AccountState(status: AccountStatus.signedOut));
        return;
      }
      _fail(AccountOperation.restore, error);
    } on Object catch (error) {
      _fail(AccountOperation.restore, error);
    }
  }

  /// Revokes the server session before clearing its local credential.
  Future<bool> signOut() async {
    if (state.isBusy) return false;
    final customer = state.customer;
    emit(AccountState(
      status: AccountStatus.loading,
      customer: customer,
      operation: AccountOperation.signOut,
    ));
    try {
      final session = await args.sessions.read();
      if (session != null && !session.isExpiredAt(args.now())) {
        await args.api.signOut();
      }
      await args.sessions.clear();
      emit(const AccountState(status: AccountStatus.signedOut));
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await args.sessions.clear();
        emit(const AccountState(status: AccountStatus.signedOut));
        return true;
      }
      _fail(AccountOperation.signOut, error, customer: customer);
      return false;
    } on Object catch (error) {
      _fail(AccountOperation.signOut, error, customer: customer);
      return false;
    }
  }

  void _fail(
    AccountOperation operation,
    Object error, {
    Customer? customer,
  }) {
    emit(AccountState(
      status: AccountStatus.failed,
      customer: customer,
      operation: operation,
      message: _accountMessageOf(error, operation),
    ));
  }
}
