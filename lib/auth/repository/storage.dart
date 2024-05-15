import 'dart:convert';
import 'package:flutter_quotes/auth/model/user.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';

/*
LoginStore can be used by AuthRepository to store and retrieve login sessions.
It simply stores the currently logged-in user (i.e. the User object) using the Hive package.
The user can later (e.g. after an app restart) be retrieved to automatically log the user back in.

In an actual application we would probably also store some kind of token e.g. JWT.
*/
abstract class LoginStore {
  Future<bool> storeLogin(User user);
  Future<bool> deleteLogin();
  Future<User?> getLogin();
}

class HiveLoginStore implements LoginStore {
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

  @override
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

  @override
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

  @override
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
