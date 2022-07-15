import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_sample/auth/auth_cubit.dart';
import 'package:flutter_sample/auth/login/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginCubit', () {
    late AuthCubit authCubit;

    blocTest<LoginCubit, LoginState>('correct initial state',
      setUp: () => authCubit = AuthCubit(),
      build: () => LoginCubit(authCubit: authCubit),
      verify: (c) {
        expect(c.state, const LoginState(
          email: '',
          password: '',
          loginInProgress: false,
          loginResult: null,
        ));
      },
    );

    blocTest<LoginCubit, LoginState>('changing username and password works',
      setUp: () => authCubit = AuthCubit(),
      build: () => LoginCubit(authCubit: authCubit),
      wait: const Duration(milliseconds: 10),
      act: (c) {
        c.setEmail('xyz');
        c.setPassword('123');
        c.setEmail('abc');
      },
      expect: () => [
        const LoginState(
          email: 'xyz',
        ),
        const LoginState(
          email: 'xyz',
          password: '123',
        ),
        const LoginState(
          email: 'abc',
          password: '123',
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>('resetting login result works',
      setUp: () => authCubit = AuthCubit(),
      build: () => LoginCubit(authCubit: authCubit),
      seed: () => const LoginState(
        email: 'abc',
        password: '123',
        loginResult: LoginResult.error,
      ),
      wait: const Duration(milliseconds: 10),
      act: (c) {
        c.resetResult();
      },
      expect: () => [
        const LoginState(
          email: 'abc',
          password: '123',
          loginResult: null,
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>('login works',
      setUp: () => authCubit = AuthCubit(),
      build: () => LoginCubit(authCubit: authCubit),
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        c.setEmail('abc');
        c.setPassword('123');
        await c.login();
        c.resetResult();
        c.setEmail('admin@admin.com');
        await c.login();
      },
      expect: () => [
        const LoginState(
          email: 'abc',
        ),
        const LoginState(
          email: 'abc',
          password: '123',
        ),
        const LoginState(
          loginInProgress: true,
          email: 'abc',
          password: '123',
        ),
        const LoginState(
          loginInProgress: false,
          loginResult: LoginResult.success,
          email: 'abc',
          password: '123',
        ),
        const LoginState(
          loginInProgress: false,
          loginResult: null,
          email: 'abc',
          password: '123',
        ),
        const LoginState(
          loginInProgress: false,
          loginResult: null,
          email: 'admin@admin.com',
          password: '123',
        ),
        const LoginState(
          loginInProgress: true,
          loginResult: null,
          email: 'admin@admin.com',
          password: '123',
        ),
        const LoginState(
          loginInProgress: false,
          loginResult: LoginResult.error,
          email: 'admin@admin.com',
          password: '123',
        ),
      ],
    );
  });
}