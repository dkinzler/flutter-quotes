import 'package:flutter_quotes/home/home_screen.dart';
import 'package:flutter_quotes/search/search_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'robots/login.dart';
import 'package:flutter_quotes/main.dart' as app;

/*
How integration testing is implemented in this app
--------------------------------------------------

We basically use the same approach to integration testing
as described in the following blog post by Very Good Ventures:
https://verygood.ventures/blog/robot-testing-in-flutter

For each feature/component of the app we implement a "robot".
A robot is a class that provides a simple set of methods to emulate
the actions (entering text, scrolling, tapping on icons/buttons, navigating, ...) 
an actual human user would perform in the app.
The robot class hides all the implementation details of performing the actions
using the flutter testing framework.
Having these robots intended to emulate user behaviour, it becomes very easy
to implement and understand integration tests.

Consider e.g. the login flow of an application.
A user starts the app and arrives on the login screen, where they can enter their 
username and password and then tap the login button to login. If the login is successful
the app will move the home screen.
Using the testing approach above, we would implement a class LoginRobot that provides methods to
enter a username, enter a password, tap the login button.
Furthermore we would have a HomeRobot that provides a method to check if the home screen is currently shown in the app. *¹
Writing a test to test the login flow then becomes as simple as:

...
await loginRobot.enterUsername('testiTester1234');
await loginRobot.enterPassword('aVerySecurePassword');
await loginRobot.tapLoginButton();
await homeRobot.verifyIsHomeScreenShown();
...


To make it easier to implement the robot classes, we can extend the base Robot class, which already
provides methods to enter text, tap buttons, scroll, etc.
Usually the method of robot subclasses just have to call one of these methods with the appropriate AppKey or widget type 
to define which widget the robot should interact with.


*¹ Of course HomeRobot would have many more methods to navigate between tabs, press buttons, etc., 
but for the pruposes of this example we just need that one method.
*/

/*
//TODO write a little todo text here
maybe set bool here to take screenshots or not
and then explain that we could make this more elaborate by e.g. writing a little test script 
that runs the flutter test command and takes a prameter to take screenshots or not
this parameter could then be passed in here
*/

/*
We just implement a single integration test here
that moves through the different features and screens of the app.
*/
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
      setUp(tester, 'login works');

      await app.main();
      await tester.pumpAndSettle();

      await robot.enterEmail('test@test.org');
      await robot.enterPassword('test123');
      await robot.tapLoginButton();

      await robot.verifyWidgetIsShown(HomeScreen);
      await robot.verifyWidgetIsShown(SearchScreen);
    });
  });
}
