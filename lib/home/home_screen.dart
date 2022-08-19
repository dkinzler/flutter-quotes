import 'package:flutter/material.dart';
import 'package:flutter_quotes/explore/explore_screen.dart';
import 'package:flutter_quotes/favorites/ui/actions.dart';
import 'package:flutter_quotes/home/actions.dart';
import 'package:flutter_quotes/home/appbar.dart';
import 'package:flutter_quotes/search/actions.dart';
import 'package:flutter_quotes/favorites/ui/favorites_screen.dart';
import 'package:flutter_quotes/home/nav.dart';
import 'package:flutter_quotes/routing/routing.dart';
import 'package:flutter_quotes/search/search_screen.dart';
import 'package:flutter_quotes/theme/theme.dart';

class HomeScreen extends StatefulWidget {
  final HomeTab tab;

  const HomeScreen({Key? key, required this.tab}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: _tabToIndex(widget.tab),
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      _tabController.animateTo(_tabToIndex(widget.tab));
    }
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.layout == Layout.mobile;

    Widget body = TabBarView(
      controller: _tabController,
      children: const [
        ExploreScreen(),
        SearchScreen(),
        FavoritesScreen(),
      ],
    );

    if (!isMobile) {
      body = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavRail(selectedTab: widget.tab),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      );
    }

    PreferredSizeWidget? appBar;
    if (isMobile) {
      appBar = CustomAppBar();
    }

    return Actions(
      actions: <Type, Action<Intent>>{
        ...getSearchActions(context),
        ...getHomeActions(context),
        ...getFavoriteActions(context),
      },
      child: Scaffold(
        appBar: appBar,
        bottomNavigationBar:
            isMobile ? BottomNavBar(selectedTab: widget.tab) : null,
        body: SafeArea(child: body),
      ),
    );
  }
}
