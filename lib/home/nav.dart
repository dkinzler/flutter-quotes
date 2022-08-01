import 'package:flutter/material.dart';
import 'package:flutter_sample/home/actions.dart';
import 'package:flutter_sample/routing/routing.dart';
import 'package:flutter_sample/theme/theme.dart';

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
      leading: IconButton(
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
            Icons.home,
          ),
          label: Text(
            'Explore',
          ),
        ),
        NavigationRailDestination(
          icon: Icon(
            Icons.search,
          ),
          label: Text(
            'Search',
          ),
        ),
        NavigationRailDestination(
          icon: Icon(
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
      //Navigation rail places the widgets for the navigation destinations and the trailing widget inside a column
      //that's why we can use expanded
      trailing: Expanded(
        //Use a nested navigation rail to form two groups of destinations
        //i.e. one for the actual tabs: explore, search, favorites
        //and one for settings and logout
        child: NavigationRail(
          extended: extended,
          minExtendedWidth: minExtendedWidth,
          selectedIndex: null,
          //align widgets to the bottom
          groupAlignment: 1.0,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(
                Icons.settings,
              ),
              label: Text(
                'Settings',
              ),
            ),
            NavigationRailDestination(
              icon: Icon(
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
            icon: Icon(Icons.home),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
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
