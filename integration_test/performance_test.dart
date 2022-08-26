import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'robots/favorites.dart';
import 'robots/home.dart';
import 'robots/login.dart';
import 'main_integration.dart' as app;
import 'robots/search.dart';

Future<void> main() async {
  var binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  //this is only necessary in profile mode to allow the test to enter text
  binding.testTextInput.register();

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

    await binding.traceAction(() async {
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
      await searchRobot.tapFavoriteQuoteButton(3);
      await searchRobot.tapFavoriteQuoteButton(5);
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
    }, reportKey: 'performance_timeline');
  });
}
