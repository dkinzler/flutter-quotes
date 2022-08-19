import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/auth/auth_cubit.dart';
import 'package:flutter_quotes/auth/login/login_cubit.dart';
import 'package:flutter_quotes/auth/login/login_screen.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/theme/app_theme.dart';
import 'package:flutter_quotes/widgets/error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  group('LoginForm', () {
    late LoginCubit loginCubit;

    setUp(() {
      loginCubit = LoginCubit(authCubit: MockAuthCubit());
    });

    /*
    Here we test that the correct widgets are shown in the login form based on the state of the LoginCubit.
    E.g. while a login is in progress, the login button should not be shown but instead a progress indicator.
    */
    testWidgets('LoginForm correct widgets shown based on LoginCubit state',
        (tester) async {
      await tester.pumpWidget(buildLoginForm(loginCubit));
      //if login is not in progress and there is no result, only the login button is shown
      expect(find.byType(LoginForm), findsOneWidget);

      var loginButtonFinder = find.byKey(const ValueKey(AppKey.loginButton));
      var progressIndicatorFinder = find.byType(CircularProgressIndicator);
      var errorFinder = find.byType(ErrorText);

      expect(loginButtonFinder, findsOneWidget);
      expect(progressIndicatorFinder, findsNothing);
      expect(errorFinder, findsNothing);

      //if login is in progress a progress indicator is shown
      loginCubit.emit(const LoginState(
        loginInProgress: true,
      ));
      //can't use pumpAndSettle since the progress indicator is animated
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

Widget buildLoginForm(LoginCubit cubit) {
  return MaterialApp(
    builder: AppTheme.appBuilder,
    home: Scaffold(
      body: BlocProvider<LoginCubit>.value(
        value: cubit,
        child: const LoginForm(),
      ),
    ),
  );
}
