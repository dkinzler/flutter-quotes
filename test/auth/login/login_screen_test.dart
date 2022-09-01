import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/auth/login/login_cubit.dart';
import 'package:flutter_quotes/auth/login/login_screen.dart';
import 'package:flutter_quotes/auth/repository/auth_repository.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../widget_test_helpers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginForm', () {
    late LoginCubit loginCubit;
    late Widget widget;

    setUp(() {
      loginCubit = LoginCubit(authRepository: MockAuthRepository());
      widget = buildWidget(BlocProvider.value(
        value: loginCubit,
        child: const LoginForm(),
      ));
    });

    testWidgets('LoginForm correct widgets shown based on LoginCubit state',
        (tester) async {
      await tester.pumpWidget(widget);
      var loginButtonFinder = find.byKey(const ValueKey(AppKey.loginButton));
      var progressIndicatorFinder = find.byType(CircularProgressIndicator);
      var errorFinder = find.byKey(const ValueKey(AppKey.loginErrorMessage));

      //if login is not in progress and there is no result, only the login button is shown
      expect(find.byType(LoginForm), findsOneWidget);
      expect(loginButtonFinder, findsOneWidget);
      expect(progressIndicatorFinder, findsNothing);
      expect(errorFinder, findsNothing);

      //if login is in progress a progress indicator is shown
      loginCubit.emit(const LoginState(
        loginInProgress: true,
      ));
      //can't use pumpAndSettle since the progress indicator is animated
      //pumpAndSettle would never stop, because the animation won't finish until the login completes
      //and the cubit state changes
      await tester.pump(const Duration(milliseconds: 10));
      expect(loginButtonFinder, findsNothing);
      expect(progressIndicatorFinder, findsOneWidget);
      expect(errorFinder, findsNothing);

      //if loginResult contains an error, an error text should be shown
      loginCubit.emit(const LoginState(
          loginInProgress: false, loginResult: LoginResult.error));
      await tester.pumpAndSettle();
      expect(loginButtonFinder, findsOneWidget);
      expect(progressIndicatorFinder, findsNothing);
      expect(errorFinder, findsOneWidget);
    });
  });
}
