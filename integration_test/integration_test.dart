import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'robots/favorites.dart';
import 'robots/home.dart';
import 'robots/login.dart';
import 'main_integration.dart' as app;
import 'robots/robot.dart';
import 'robots/search.dart';

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
We just implement a single integration test here
that moves through the different features and screens of the app.
For an actual production app we could easily add tests for many more scenarios.
*/
Future<void> main() async {
  var binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /*
  TODO
  We can also use integration tests to automatically collect screenshots of the app
  on different devices and screen sizes.
  Right now we manually enable screenshot taking here in the test code.
  However it would not be hard to write a custom test script that takes a parameter to enable/disable
  screenshot taking. The script can pass the arguments to the flutter drive/flutter test command using the --dart-define option and
  the value can then be read in the code here using e.g. bool.fromEnvironment('paramName').
  */
  Robot.disableScreenshots();

  testWidgets('happy path', (WidgetTester tester) async {
    var loginRobot = LoginRobot(
      tester: tester,
      binding: binding,
      testName: 'happypath',
    );

    var homeRobot = HomeRobot(
      tester: tester,
      binding: binding,
      testName: 'happypath',
    );

    var searchRobot = SearchRobot(
      tester: tester,
      binding: binding,
      testName: 'happypath',
    );

    var favoritesRobot = FavoritesRobot(
      tester: tester,
      binding: binding,
      testName: 'happypath',
      actionDelay: const Duration(seconds: 1),
    );

    await app.mainIntegrationTest();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    await loginRobot.closeTipDialog();
    await loginRobot.verifyLoginScreenIsShown();
    await loginRobot.enterEmail('test@test.org');
    await loginRobot.enterPassword('test123');
    await loginRobot.tapLoginButton();

    await homeRobot.verifyHomeScreenIsShown();
    await homeRobot.verifyExploreScreenIsShown();

    await homeRobot.gotoSearchScreen();
    await homeRobot.verifySearchScreenIsShown();
    await searchRobot.enterSearchTerm('test search');
    await searchRobot.tapSearchButton();
    await searchRobot.tapFavoriteQuoteButton(0);
    await searchRobot.tapFavoriteQuoteButton(1);
    await searchRobot.tapFavoriteQuoteButton(2);
    await searchRobot.scrollDown();
    await searchRobot.tapLoadMoreButton();
    await searchRobot.scrollDown();

    await homeRobot.gotoFavoritesScreen();
    await homeRobot.verifyFavoritesScreenIsShown();
    await favoritesRobot.verifyFavoritesAreShown(count: 3);
    await favoritesRobot.changeSortOrderToOldest();
    //nothing should be found here
    await favoritesRobot.enterFilterTerm('%&/(');
    await favoritesRobot.verifyNoFavoritesAreShown();
    await favoritesRobot.clearFilterTerm();
    await favoritesRobot.verifyFavoritesAreShown(count: 3);
    await favoritesRobot.openAddFilterTagsDialog();
    await favoritesRobot.verifyAddFilterTagsDialogIsShown();
    await favoritesRobot.addFilterTag();
    await favoritesRobot.closeAddFilterTagsDialog();

    await homeRobot.gotoSearchScreen();
    await homeRobot.verifySearchScreenIsShown();
    await homeRobot.gotoSettingsScreen();
    await homeRobot.verifiySettingsScreenIsShown();
    await homeRobot.goBack();
    await homeRobot.logout();
    await loginRobot.verifyLoginScreenIsShown();
  });
}
