import 'package:flutter/material.dart';
import 'package:flutter_quotes/home/actions.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/routing/routing.dart';
import 'package:flutter_quotes/theme/theme.dart';

class NavRail extends StatefulWidget {
  final HomeTab selectedTab;

  const NavRail({Key? key, required this.selectedTab}) : super(key: key);

  @override
  State<NavRail> createState() => _NavRailState();
}

class _NavRailState extends State<NavRail> {
  bool extended = false;

  @override
  Widget build(BuildContext context) {
    Widget extendIcon = const Icon(Icons.double_arrow);
    if (extended) {
      extendIcon = Transform.scale(
        scaleX: -1.0,
        child: extendIcon,
      );
    }

    var minExtendedWidth = 232 * context.appTheme.scale;

    return NavigationRail(
      extended: extended,
      minExtendedWidth: minExtendedWidth,
      selectedIndex: _tabToIndex(widget.selectedTab),
      labelType: NavigationRailLabelType.none,
      leading: IconButton(
        key: const ValueKey(AppKey.drawerExtendButton),
        icon: extendIcon,
        onPressed: () {
          setState(() {
            extended = !extended;
          });
        },
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(
            key: ValueKey(AppKey.drawerExploreButton),
            Icons.explore,
          ),
          label: Text(
            'Explore',
          ),
        ),
        NavigationRailDestination(
          icon: Icon(
            key: ValueKey(AppKey.drawerSearchButton),
            Icons.search,
          ),
          label: Text(
            'Search',
          ),
        ),
        NavigationRailDestination(
          icon: Icon(
            key: ValueKey(AppKey.drawerFavoritesButton),
            Icons.favorite,
          ),
          label: Text(
            'Favorites',
          ),
        ),
      ],
      onDestinationSelected: (index) {
        context.go(HomeRoute(tab: _indexToTab(index)));
      },
      // Navigation rail places the widgets for the navigation destinations and the trailing widget inside a column
      // that's why we can use expanded
      trailing: Expanded(
        // Use a nested navigation rail to form two groups of destinations
        // i.e. one for the actual tabs: explore, search, favorites
        // and one for settings and logout
        child: NavigationRail(
          extended: extended,
          minExtendedWidth: minExtendedWidth,
          selectedIndex: null,
          //align widgets to the bottom
          groupAlignment: 1.0,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(
                key: ValueKey(AppKey.drawerSettingsButton),
                Icons.settings,
              ),
              label: Text(
                'Settings',
              ),
            ),
            NavigationRailDestination(
              icon: Icon(
                key: ValueKey(AppKey.drawerLogoutButton),
                Icons.logout,
              ),
              label: Text(
                'Logout',
              ),
            ),
          ],
          onDestinationSelected: (index) {
            if (index == 0) {
              Actions.invoke<OpenSettingsIntent>(
                  context, const OpenSettingsIntent());
            } else {
              Actions.invoke<LogoutIntent>(context, const LogoutIntent());
            }
          },
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final HomeTab selectedTab;

  const BottomNavBar({
    Key? key,
    required this.selectedTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        selectedItemColor: context.theme.colorScheme.primary,
        currentIndex: _tabToIndex(selectedTab),
        onTap: (index) {
          context.go(HomeRoute(tab: _indexToTab(index)));
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              key: ValueKey(AppKey.navbarExploreButton),
              Icons.explore,
            ),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              key: ValueKey(AppKey.navbarSearchButton),
              Icons.search,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              key: ValueKey(AppKey.navbarFavoritesButton),
              Icons.favorite,
            ),
            label: 'Favorites',
          ),
        ]);
  }
}

int _tabToIndex(HomeTab tab) {
  switch (tab) {
    case HomeTab.search:
      return 1;
    case HomeTab.favorites:
      return 2;
    default:
      return 0;
  }
}

HomeTab _indexToTab(int index) {
  switch (index) {
    case 1:
      return HomeTab.search;
    case 2:
      return HomeTab.favorites;
    default:
      return HomeTab.explore;
  }
}
