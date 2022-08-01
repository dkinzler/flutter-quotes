import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_sample/auth/auth_cubit.dart';
import 'package:flutter_sample/auth/user.dart';
import 'package:flutter_sample/util/time.dart';
import 'package:test/test.dart';

void main() {
  var timeNow = DateTime(2022);
  currentTime = () => timeNow;

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'correct initial state',
      build: () => AuthCubit(storeLogin: false),
      verify: (c) => expect(c.state, const AuthState.unknown()),
    );

    test('login fails if username or password empty', () async {
      var authCubit = AuthCubit(storeLogin: false);
      var result = await authCubit.login(email: '', password: 'somepw');
      expect(result, LoginResult.wrongCredentials);
      result = await authCubit.login(email: 'xyz@abc.de', password: '');
      expect(result, LoginResult.wrongCredentials);
    });

    blocTest<AuthCubit, AuthState>('login and logout works',
        build: () => AuthCubit(storeLogin: false),
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
      build: () => AuthCubit(storeLogin: false),
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await c.login(email: 'admin@admin.com', password: 'somepw');
      },
      expect: () => [],
    );
  });
}
