import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/actions/search.dart';
import 'package:flutter_sample/favorites/favorites_screen.dart';
import 'package:flutter_sample/home/nav.dart';
import 'package:flutter_sample/random/random_screen.dart';
import 'package:flutter_sample/routing/routing.dart';
import 'package:flutter_sample/search/search_cubit.dart';
import 'package:flutter_sample/search/search_screen.dart';
import 'package:flutter_sample/theme/theme.dart';

class HomeScreen extends StatefulWidget {
  final HomeTab tab;

  const HomeScreen({Key? key, required this.tab}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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
      case HomeTab.random:
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
    if(oldWidget.tab != widget.tab) {
      _tabController.animateTo(_tabToIndex(widget.tab));
    }
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.layout == Layout.mobile;

    Widget body = TabBarView(
      controller: _tabController,
      children: const[
        SearchScreen(),
        RandomScreen(),
        FavoritesScreen(),
      ],
    );

    if(!isMobile) {
      body = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavRail(selectedTab: widget.tab),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      );
    }

    return Actions(
      //TODO maybe define this somewhere else with a builder function?
      actions: <Type, Action<Intent>>{
        SearchIntent: SearchAction(
          appRouter: context.read<AppRouter>(),
          searchCubit: context.read<SearchCubit>(),
        ),
        DialogIntent: DialogAction(),
      },
      child: Scaffold(
        bottomNavigationBar: isMobile ? BottomNavBar(selectedTab: widget.tab) : null,
        body: body,
      ),
    );
  }
}