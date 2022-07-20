import 'package:flutter/widgets.dart';
import 'package:flutter_sample/home/home_screen.dart';
import 'package:flutter_sample/keys.dart';
import 'package:flutter_sample/search/search_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'robot.dart';
import 'package:flutter_sample/main.dart' as app;

//TODO don't need to integration test everything, just enough to showcase how different things work

void main() {
  var binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login', () {
    late LoginRobot robot;

    void setUp(WidgetTester tester, String testName) {
      robot = LoginRobot(
        tester: tester,
        testName: testName,
        actionDelay: const Duration(seconds: 1),
        binding: binding,
      );
    }

    testWidgets('login works', (WidgetTester tester) async {
      setUp(tester, 'login');
      
      await app.main();
      await tester.pumpAndSettle();

      await robot.enterEmail('test@test.org');
      await robot.enterPassword('test123');
      await robot.tapLoginButton();

      await robot.verifyWidgetIsShown(type: HomeScreen);
      await robot.verifyWidgetIsShown(type: SearchScreen);
    });
  });
}

class LoginRobot extends Robot {
  LoginRobot({
    required super.tester,
    super.testName,
    super.actionDelay,
    super.binding,
  });

  Future<void> enterEmail(String text) => enterText(const ValueKey(AppKey.loginEmailTextField), text);

  Future<void> enterPassword(String text) => enterText(const ValueKey(AppKey.loginPasswordTextField), text);

  Future<void> tapLoginButton() => tap(const ValueKey(AppKey.loginButton));
}