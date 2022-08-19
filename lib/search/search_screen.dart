import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/search/search_bar.dart';
import 'package:flutter_quotes/search/search_cubit.dart';
import 'package:flutter_quotes/search/search_result_header.dart';
import 'package:flutter_quotes/search/search_results.dart';
import 'package:flutter_quotes/search/sliver_search_results.dart';
import 'package:flutter_quotes/theme/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

//We use the AutomaticKeepAliveClientMixin to keep this widget in the widget tree
//when we switch between tabs on the home screen.
//This is to be at the same scroll position when we move from the search screen tab to another tab and back.
//Keeping the widget around even when it's not visible will of course consume more memory, on web/desktop this should be fine.
//Normally we could more easily remember the scroll position by using a PageStorageKey
//for the ListView/GridView.
//This works for the ListView widget but not for the MasonryGridView widget from the
//flutter_staggered_grid_view package, this is probably a bug in that package.
class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _useInfiniteScroll = false;
  bool get useInfiniteScroll => _useInfiniteScroll;
  set useInfiniteScroll(bool value) {
    if (value) {
      _scrollController.addListener(_autoLoadMore);
    } else {
      _scrollController.removeListener(_autoLoadMore);
    }
    _useInfiniteScroll = value;
  }

  @override
  void initState() {
    super.initState();
  }

  bool _loadInProgress = false;
  Future<void> _autoLoadMore() async {
    var trigger = 0.9 * _scrollController.position.maxScrollExtent;
    if (!_loadInProgress && _scrollController.position.pixels > trigger) {
      _loadInProgress = true;
      await context.read<SearchCubit>().loadMoreResults();
      _loadInProgress = false;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_autoLoadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var isMobile = context.layout == Layout.mobile;

    bool showInfiniteScrollToggleButton =
        context.select<SearchCubit, bool>((c) => c.state.hasResults);
    Widget? infiniteScrollToggleButton;
    if (showInfiniteScrollToggleButton) {
      infiniteScrollToggleButton = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Infinite scroll'),
          Switch(
            value: useInfiniteScroll,
            onChanged: (value) => setState(() {
              useInfiniteScroll = value;
            }),
          ),
        ],
      );
    }

    if (isMobile) {
      //on mobile the search bar will be scrolled out of view, on tablet on desktop the search bar stays visible at the top of the screen
      //as the user scrolls through results
      var padding = context.insets.paddingM;
      return Padding(
        padding: padding,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const SliverToBoxAdapter(
              child: SearchBar(),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: context.insets.paddingM,
                  child: const SearchResultHeader(),
                ),
              ),
            ),
            if (showInfiniteScrollToggleButton)
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: context.sizes.spaceS,
                      horizontal: context.sizes.spaceM,
                    ),
                    child: infiniteScrollToggleButton,
                  ),
                ),
              ),
            const SliverSearchResultsWidget(),
          ],
        ),
      );
    } else {
      var spaceL = context.sizes.spaceL;
      return Column(children: [
        /*
        Need to apply padding to each widget separately.
        If we just wrapped the column in a padding, the scroll bar for the results list
        would be padded in as well.
        Instead we need to pass the padding to SearchResultsWidget, which can pass it directly
        to the ListView/GridView widget.
        */
        Padding(
          padding: EdgeInsets.fromLTRB(
            spaceL,
            spaceL,
            spaceL,
            0,
          ),
          child: const SearchBar(),
        ),
        Padding(
          padding: context.insets.paddingM,
          child: const SearchResultHeader(),
        ),
        if (showInfiniteScrollToggleButton)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.sizes.spaceL,
                vertical: context.sizes.spaceS,
              ),
              child: infiniteScrollToggleButton,
            ),
          ),
        Expanded(
          child: SearchResultsWidget(
            scrollController: _scrollController,
            padding: EdgeInsets.fromLTRB(
              spaceL,
              0,
              spaceL,
              spaceL,
            ),
          ),
        ),
      ]);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
