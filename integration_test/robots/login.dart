import 'package:flutter_quotes/auth/login/login_screen.dart';
import 'package:flutter_quotes/keys.dart';
import 'robot.dart';

class LoginRobot extends Robot {
  LoginRobot({
    required super.tester,
    super.testName,
    super.actionDelay,
    super.binding,
  });

  Future<void> enterEmail(String text) =>
      enterText(AppKey.loginEmailTextField, text);

  Future<void> enterPassword(String text) =>
      enterText(AppKey.loginPasswordTextField, text);

  Future<void> tapLoginButton() => tap(AppKey.loginButton);

  Future<void> verifyLogoinScreenIsShown() => verifyWidgetIsShown(LoginScreen);

  Future<void> verifyErrorMessageIsShown() =>
      verifyWidgetIsShown(AppKey.loginErrorMessage);
}
