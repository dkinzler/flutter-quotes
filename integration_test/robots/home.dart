import 'package:flutter_quotes/explore/explore_screen.dart';
import 'package:flutter_quotes/favorites/view/favorites_screen.dart';
import 'package:flutter_quotes/home/home_screen.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/search/view/search_screen.dart';
import 'package:flutter_quotes/settings/settings_screen.dart';
import 'robot.dart';

class HomeRobot extends Robot {
  HomeRobot({
    required super.tester,
    super.testName,
    super.actionDelay,
    super.binding,
  });

  // we have different layouts for mobile and tablet/desktop
  // on mobile there is a bottom navigation bar, on tablet/desktop a navigation rail
  Future<void> _goto(AppKey a, AppKey b) async {
    if (isWidgetShown(a)) {
      await tap(a);
    } else {
      await tap(b);
    }
  }

  Future<void> gotoExploreScreen() =>
      _goto(AppKey.drawerExploreButton, AppKey.navbarExploreButton);

  Future<void> gotoSearchScreen() =>
      _goto(AppKey.drawerSearchButton, AppKey.navbarSearchButton);

  Future<void> gotoFavoritesScreen() =>
      _goto(AppKey.drawerFavoritesButton, AppKey.navbarFavoritesButton);

  // on mobile we first need to open a popup menu
  Future<void> gotoSettingsScreen() async {
    if (isWidgetShown(AppKey.appbarPopupMenu)) {
      await tap(AppKey.appbarPopupMenu);
      await tap(AppKey.appbarSettingsButton);
    } else {
      await tap(AppKey.drawerSettingsButton);
    }
  }

  Future<void> logout() async {
    if (isWidgetShown(AppKey.appbarPopupMenu)) {
      await tap(AppKey.appbarPopupMenu);
      await tap(AppKey.appbarLogoutButton);
    } else {
      await tap(AppKey.drawerLogoutButton);
    }
    await tap(AppKey.logoutConfirmDialogConfirmButton);
  }

  Future<void> tapDrawerExtendButton() => tap(AppKey.drawerExploreButton);

  Future<void> verifyHomeScreenIsShown() => verifyWidgetIsShown(HomeScreen);

  Future<void> verifyExploreScreenIsShown() =>
      verifyWidgetIsShown(ExploreScreen);

  Future<void> verifySearchScreenIsShown() => verifyWidgetIsShown(SearchScreen);

  Future<void> verifyFavoritesScreenIsShown() =>
      verifyWidgetIsShown(FavoritesScreen);

  Future<void> verifiySettingsScreenIsShown() =>
      verifyWidgetIsShown(SettingsScreen);
}
