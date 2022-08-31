import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_quotes/auth/login/login_cubit.dart';
import 'package:flutter_quotes/auth/repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';

/*
These are typical Cubit tests, they have the following steps:
* create an instance of the cubit
* call some of the public methods of the cubit
* check that the sequence of states emitted by the cubit is correct

One challenge that often comes up in these tests is setting up the dependencies
of the cubit/bloc to be tested.
Here LoginCubit just has a single dependency AuthRepository which in turn doesn't have
any dependencies, so we can just create an instance of AuthRepository.
However for more complex cubits it might be easier to mock/fake the dependencies instead of creating
the whole dependency graph needed to create an instance of the cubit/bloc under test.
*/
void main() {
  group('LoginCubit', () {
    late AuthRepository authCubit;
    late LoginCubit loginCubit;

    //since the setup is the same for all tests we perform it there instead of
    //repeating the same code in each build function of blocTest
    setUp(() {
      authCubit = AuthRepository();
      loginCubit = LoginCubit(authRepository: authCubit);
    });

    blocTest<LoginCubit, LoginState>(
      'changing username and password works',
      build: () => loginCubit,
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

    blocTest<LoginCubit, LoginState>(
      'resetting login result works',
      build: () => loginCubit,
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

    blocTest<LoginCubit, LoginState>(
      'login works',
      build: () => loginCubit,
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        c.setEmail('abc');
        c.setPassword('123');
        await c.login();
        c.resetResult();
        c.setEmail('fail@test.com');
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
          email: 'fail@test.com',
          password: '123',
        ),
        const LoginState(
          loginInProgress: true,
          loginResult: null,
          email: 'fail@test.com',
          password: '123',
        ),
        const LoginState(
          loginInProgress: false,
          loginResult: LoginResult.error,
          email: 'fail@test.com',
          password: '123',
        ),
      ],
    );
  });
}
