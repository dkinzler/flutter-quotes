import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_quotes/auth/auth_cubit.dart';
import 'package:flutter_quotes/auth/user.dart';
import 'package:flutter_quotes/util/time.dart';
import 'package:test/test.dart';

void main() {
  //fix time, because AuthState contains a DateTime lastLoginTime property
  var timeNow = DateTime(2022);
  currentTime = () => timeNow;

  group('AuthCubit', () {
    late AuthCubit authCubit;

    setUp(() {
      authCubit = AuthCubit();
    });

    test('login fails if email or password empty or email starts with "fail"',
        () async {
      var result = await authCubit.login(email: '', password: 'somepw');
      expect(result, LoginResult.wrongCredentials);
      result = await authCubit.login(email: 'xyz@abc.de', password: '');
      expect(result, LoginResult.wrongCredentials);
      result = await authCubit.login(email: 'fail@abc.de', password: '');
      expect(result, LoginResult.wrongCredentials);
    });

    blocTest<AuthCubit, AuthState>('login and logout works',
        build: () => authCubit,
        wait: const Duration(milliseconds: 10),
        act: (c) async {
          await c.login(email: 'test@test.org', password: 'somepw');
          c.logout();
        },
        expect: () => [
              AuthState.authenticated(
                user: User(
                    email: 'test@test.org',
                    name: 'Testi Tester',
                    lastLoginTime: timeNow),
              ),
              const AuthState.unauthenticated(),
            ]);

    blocTest<AuthCubit, AuthState>(
      'no state change when login fails',
      build: () => authCubit,
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await c.login(email: 'fail@admin.com', password: 'somepw');
      },
      expect: () => [],
    );
  });
}
