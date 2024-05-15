import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/search/cubit/search_cubit.dart';
import 'package:flutter_quotes/search/widgets/scroll_controller.dart';
import 'package:flutter_quotes/search/widgets/widgets.dart';
import 'package:flutter_quotes/theme/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

/*
We use the AutomaticKeepAliveClientMixin to keep this widget in the widget tree
when we switch between tabs on the home screen.
This is to be at the same scroll position when we move from the search screen tab to another tab and back.
Keeping the widget around even when it's not visible will of course consume more memory, on web/desktop this should be fine.
Normally we could more easily remember the scroll position by using a PageStorageKey
for the ListView/GridView.
This works for the ListView widget but not for the MasonryGridView widget from the
flutter_staggered_grid_view package, there might be a bug in that package.
*/
class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  bool useInfiniteScroll = false;

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
      // on mobile the search bar will be scrolled out of view, on tablet on desktop the search bar stays visible at the top of the screen
      // as the user scrolls through results
      var padding = context.insets.paddingM;
      return Padding(
        padding: padding,
        child: CustomScrollView(
          controller: useInfiniteScroll
              ? InfiniteScrollController(
                  searchCubit: context.read<SearchCubit>(),
                )
              : null,
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
          padding: context.insets.paddingS,
          child: const SearchResultHeader(),
        ),
        if (showInfiniteScrollToggleButton)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(spaceL, 0, spaceL, context.sizes.spaceS),
              child: infiniteScrollToggleButton,
            ),
          ),
        Expanded(
          child: SearchResultsWidget(
            scrollController: useInfiniteScroll
                ? InfiniteScrollController(
                    searchCubit: context.read<SearchCubit>(),
                  )
                : null,
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
