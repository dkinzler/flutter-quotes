import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/auth/auth_cubit.dart';
import 'package:flutter_sample/routing/routing.dart';

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
    //TODO if window gets too small we can't display it all, then a listview would be better, but with the ListView can we easily make it so that logout and settings is at the bottom?
    //should be fine though, if not use a singleChildScrollView
    return NavigationRail(
      extended: extended,
      selectedIndex: _tabToIndex(widget.selectedTab),
      leading: IconButton(
        icon: const Icon(Icons.double_arrow),
        onPressed: () {
          setState(() {
            extended = !extended;
          });
        },
      ),
      destinations: const[
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
            Icons.favorite_border,
          ),
          label: Text(
            'Favorites',
          ),
        ),
      ],
      onDestinationSelected: (index) {
        context.go(HomeRoute(tab: _indexToTab(index)));
      },
      trailing:IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () => context.read<AuthCubit>().logout(),
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
      currentIndex: _tabToIndex(selectedTab),
      onTap: (index) {
        context.go(HomeRoute(tab: _indexToTab(index)));
      },
      items: const[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favorites',
        ),
      ]
    );
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