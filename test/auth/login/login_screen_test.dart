import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/auth/auth_cubit.dart';
import 'package:flutter_quotes/auth/login/login_cubit.dart';
import 'package:flutter_quotes/auth/login/login_screen.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../widget_test_helpers.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

/*
This is a typical widget test.
We check that based on the state of the app/widget the correct ui is shown.

Here we test the LoginForm widget which shows different ui elements based 
on the state of LoginCubit:
* if the user presses the login button, the app sends the login credentials to some backend
  service to authenticate, while this is in progress a CircularProgressIndicator
  is shown instead of the login button
* if the login fails, show an error message
*/
void main() {
  group('LoginForm', () {
    late LoginCubit loginCubit;
    late Widget widget;

    setUp(() {
      loginCubit = LoginCubit(authCubit: MockAuthCubit());
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
