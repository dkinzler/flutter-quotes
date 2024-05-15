import 'package:flutter_quotes/auth/model/user.dart';
import 'package:flutter_quotes/auth/repository/storage.dart';
import 'package:flutter_quotes/util/time.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

/*
AuthRepository maintains the authentication state of the application.
Use the "currentUser" getter to obtain a stream of User objects that is updated
every time a user logs in or out.
If no user is logged in, the stream will emit User.empty, i.e. we can use "user.isEmpty" to check
whether a user is currently logged in or not.
To make listening to the user stream more convenient, the latest User object will be emitted to every new subscription.

To persist a login session, AuthRepository can use an instance of LoginStore.
*/

/*
The result of a login attempt:
- wrongCredentials: wrong email or password
- error: login failed, e.g. because there is no internet connection, the backend authentication system is down, ...
*/
enum LoginResult { success, wrongCredentials, error }

class AuthRepository {
  final _log = Logger('AuthRepository');
  final LoginStore? _loginStore;

  AuthRepository({
    LoginStore? loginStore,
  }) : _loginStore = loginStore {
    if (_loginStore != null) {
      _loginSilent();
    }
  }

  // use BehaviorSubject to cache the latest value
  // the latest value will always be emitted to new subscriptions
  final _streamController = BehaviorSubject<User>.seeded(User.empty);

  // since the stream is seeded, there should always be a value available
  User get user => _streamController.value;

  Stream<User> get currentUser => _streamController.asBroadcastStream();

  void _add(User u) {
    if (user != u) _streamController.add(u);
  }

  Future<void> _loginSilent() async {
    var user = await _loginStore?.getLogin();
    if (user != null) {
      _add(user);
    }
  }

  // any email/password combination will be accepted
  // except any email that starts with 'fail', which can be used to trigger an error (e.g. to test the UI)
  Future<LoginResult> login(
      {required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      _log.info('login attempt with empty email or password');
      return LoginResult.wrongCredentials;
    } else if (email.startsWith('fail')) {
      _log.info('login failed');
      return LoginResult.error;
    } else {
      var user = User(
        email: email,
        name: 'Testi Tester',
        // use the currentTime function instead of Date.now() directly
        // that way we can override the currentTime function for tests to make the DateTime object that is returned predictable
        lastLoginTime: currentTime(),
      );
      _add(user);
      _loginStore?.storeLogin(user);
      return LoginResult.success;
    }
  }

  void logout() {
    _add(User.empty);
    _loginStore?.deleteLogin();
  }

  Future<void> close() => _streamController.close();
}
