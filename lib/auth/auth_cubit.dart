import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/auth/user.dart';
import 'package:flutter_quotes/util/time.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';

/*
There are 3 different authentication states the app can be in:
- unknown: initial state on startup
    there might be a previous login session that was saved and can be restored
- unauthenticated: no user is logged in
- authenticated: user logged in
*/

enum AuthStatus { unknown, unauthenticated, authenticated }

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

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        user = const User.empty();

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = const User.empty();

  const AuthState.authenticated({
    required this.user,
  }) : status = AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, user];
}

/*
The result of a login attempt:
- wrongCredentials: wrong email or password
- error: login failed, e.g. because there is no internet connection, the backend authentication system is down, ...
*/
enum LoginResult { success, wrongCredentials, error }

class AuthCubit extends Cubit<AuthState> {
  final _log = Logger('AuthCubit');
  LoginStore? _loginStore;

  AuthCubit({
    //whether or not store logins, can be turned off e.g. to make testing easier
    bool storeLogin = true,
    //the login store to tuse if storeLogin=true, if null a new instance of the LoginStore class is used
    LoginStore? loginStore,
  }) : super(const AuthState.unknown()) {
    if (storeLogin) {
      _loginStore = loginStore ?? LoginStore();
      _loginSilent();
    }
  }

  Future<void> _loginSilent() async {
    var user = await _loginStore?.getLogin();
    if (user != null) {
      emit(AuthState.authenticated(user: user));
    }
  }

  //any email/password combination will be accepted
  //except "admin@admin.com" which can be used to trigger an error (e.g. to test the UI)
  Future<LoginResult> login(
      {required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      _log.info('login attempt with empty email or password');
      return LoginResult.wrongCredentials;
    } else if (email == 'admin@admin.com') {
      _log.info('login failed');
      return LoginResult.error;
    } else {
      var user = User(
        email: email,
        name: 'Testi Tester',
        //use the currentTime function instead of directly Date.now()
        //that way we can override the currentTime function for tests to make the DateTime object that is returned predictable
        lastLoginTime: currentTime(),
      );
      emit(AuthState.authenticated(user: user));
      _loginStore?.storeLogin(user);
      return LoginResult.success;
    }
  }

  void logout() {
    emit(const AuthState.unauthenticated());
    _loginStore?.deleteLogin();
  }
}

/*
LoginStore can be used by AuthCubit to store and retrieve login sessions.
It simply stores the currently logged-in user (i.e. the User object) using the Hive package.
The user can later (e.g. after an app restart) be retrieved to automatically log the user back in.

In an actual application we would probably also store some kind of token (e.g. JWT) instead of just the user object containing the user's email and name.
*/
class LoginStore {
  final _log = Logger('LoginStore');

  Box<String>? _box;
  bool get isInitialized => _box != null;

  Future<bool> _init() async {
    try {
      _box = await Hive.openBox<String>('loginStore');
      return true;
    } catch (e) {
      _log.warning('could not init login store', e);
      return false;
    }
  }

  Future<bool> storeLogin(User user) async {
    if (!isInitialized) {
      var initSuccess = await _init();
      if (!initSuccess) {
        return false;
      }
    }
    try {
      var userAsJson = jsonEncode(user.toMap());
      await _box?.put('user', userAsJson);
      return true;
    } catch (e) {
      _log.warning('could not store login');
      return false;
    }
  }

  Future<bool> deleteLogin() async {
    if (!isInitialized) {
      var initSuccess = await _init();
      if (!initSuccess) {
        return false;
      }
    }
    try {
      await _box?.delete('user');
      return true;
    } catch (e) {
      _log.warning('could not store login');
      return false;
    }
  }

  Future<User?> getLogin() async {
    if (!isInitialized) {
      var initSuccess = await _init();
      if (!initSuccess) {
        return null;
      }
    }
    try {
      var userAsJson = _box?.get('user');
      if (userAsJson != null) {
        return User.fromMap(jsonDecode(userAsJson));
      }
      return null;
    } catch (e) {
      _log.warning('could not store login');
      return null;
    }
  }
}
