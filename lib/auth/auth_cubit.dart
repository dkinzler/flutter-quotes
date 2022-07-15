import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_sample/auth/user.dart';
import 'package:logging/logging.dart';

/*
There are 3 different authentication states the app can be in:
- unknown: initial state on startup
    there might be a previous login session that was saved and can be restored
- unauthenticated: no user is logged in, show login screen in UI
- authenticated: user logged in
*/

enum AuthStatus {unknown, unauthenticated, authenticated}

class AuthState extends Equatable {
  final AuthStatus status;
  //the currently authenticated user or User.empty() if not authenticated
  final User user;

  bool get isUnknown => status == AuthStatus.unknown;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  const AuthState({
    required this.status,
    this.user = const User.empty(),
  });

  const AuthState.unknown() :
    status = AuthStatus.unknown,
    user = const User.empty();

  const AuthState.unauthenticated() :
    status = AuthStatus.unauthenticated,
    user = const User.empty();

  const AuthState.authenticated({
    required this.user,
  }) :
    status = AuthStatus.authenticated;
  
  @override
  List<Object?> get props => [status, user];
}

/*
The result of a login attempt:
- wrongCredentials: wrong email or password
- error: login failed, e.g. because there is no internet connection, the backend authentication system is down, ...
*/
enum LoginResult {success, wrongCredentials, error}

class AuthCubit extends Cubit<AuthState> {
  final _log = Logger('AuthCubit');

  AuthCubit() : super(const AuthState.unknown());

  //any email/password combination will be accepted
  //except "admin@admin.com" which can be used to trigger an error (e.g. to test the UI)
  Future<LoginResult> login({required String email, required String password}) async {
    if(email.isEmpty || password.isEmpty) {
      _log.info('login attempt with empty email or password');
      return LoginResult.wrongCredentials;
    } else if(email == 'admin@admin.com') {
      _log.info('login failed');
      return LoginResult.error;
    } else {
      emit(AuthState.authenticated(
        user: User(email: email),
      ));
      return LoginResult.success;
    }
  }

  void logout() {
    emit(const AuthState.unauthenticated());
  }
}