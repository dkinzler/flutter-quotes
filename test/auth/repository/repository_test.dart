import 'package:flutter_quotes/auth/model/user.dart';
import 'package:flutter_quotes/auth/repository/auth_repository.dart';
import 'package:flutter_quotes/util/time.dart';
import 'package:test/test.dart';

void main() {
  // fix time, because AuthState contains a DateTime lastLoginTime property
  var timeNow = DateTime(2022);
  currentTime = () => timeNow;

  group('AuthRepository', () {
    late AuthRepository authRepository;

    setUp(() {
      authRepository = AuthRepository();
    });

    test('login fails if email or password empty or email starts with "fail"',
        () async {
      var result = await authRepository.login(email: '', password: 'somepw');
      expect(result, LoginResult.wrongCredentials);
      result = await authRepository.login(email: 'xyz@abc.de', password: '');
      expect(result, LoginResult.wrongCredentials);
      result = await authRepository.login(email: 'fail@abc.de', password: '');
      expect(result, LoginResult.wrongCredentials);
    });

    test('login and logout works', () async {
      var userStream = authRepository.currentUser;

      expectLater(
          userStream,
          emitsInOrder([
            User.empty,
            User(
                email: 'test@test.org',
                name: 'Testi Tester',
                lastLoginTime: timeNow),
            User.empty,
          ]));

      expect(authRepository.user, User.empty);
      var result = await authRepository.login(
          email: 'test@test.org', password: 'somepw');
      expect(result, LoginResult.success);
      expect(
          authRepository.user,
          User(
              email: 'test@test.org',
              name: 'Testi Tester',
              lastLoginTime: timeNow));
      authRepository.logout();
      expect(authRepository.user, User.empty);
    });

    test('no user emitted when login fails', () async {
      var userStream = authRepository.currentUser;

      expectLater(userStream, emitsInOrder([User.empty]));

      await authRepository.login(email: 'fail@admin.org', password: 'somepw');
    });
  });
}
