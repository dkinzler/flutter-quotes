import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/search/search_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/error.dart';
import 'package:flutter_sample/widgets/quote.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'actions.dart';

/*
SearchResultsWidget displays the search results from SearchCubit.

Different widgets will be shown based on the results and current status of the search:
- a ListView/MasonryGridView of quotes, if the list of results quotes is not empty 
- a progress indicator if (more) results are currently being loaded
- a retry button if an error occured while loading results
- a button to load more results, if more results are available 
- text indicating that there are no (more) results
*/
class SearchResultsWidget extends StatefulWidget {
  final bool useInfiniteScroll;

  const SearchResultsWidget({
    Key? key,
    this.useInfiniteScroll = false,
  }) : super(key: key);

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  final ScrollController _scrollController = ScrollController();

  bool _loadInProgress = false;

  @override
  void initState() {
    super.initState();

    if (widget.useInfiniteScroll) {
      _scrollController.addListener(_autoLoadMore);
    }
  }

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
    var state = context.watch<SearchCubit>().state;
    var status = state.status;

    if (!state.hasResults) {
      Widget child;
      if (status == SearchStatus.idle) {
        child = const Text('Enter a search term...');
      } else if (status == SearchStatus.inProgress) {
        child = const CircularProgressIndicator();
      } else {
        child = ErrorRetryWidget(
          onPressed: () => context.read<SearchCubit>().search(),
        );
      }

      return Center(child: child);
    }

    //if there are search results, those results will always be shown
    //any loading indicators or error widgets will be shown at the end of the results
    var quotes = state.quotes!;
    if (quotes.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    //an extra widget will always be shown in the search results list
    //either a progress indicator, error widget, button to load more results or a text indicating that there are no more results
    var itemCount = quotes.length + 1;

    //we will choose how to present the list of quotes based on the available space/size of the screen
    //on smaller screens we will show the results in a linear list using a ListView
    //on larger screens we have multiple columns using a MasonryGridView

    //we can use the same builder function for ListView and MasonryGridView
    itemBuilder(BuildContext context, int index) {
      if (index < quotes.length) {
        return QuoteCard(
          quote: quotes[index],
          quoteTextStyle: const TextStyle(color: Colors.white),
          authorTextStyle: const TextStyle(color: Colors.white),
          showTags: true,
          onTagPressed: (String tag) {
            Actions.invoke<SearchIntent>(context, SearchIntent(query: tag));
          },
        );
      }

      Widget child;
      if (status == SearchStatus.inProgress) {
        child = const CircularProgressIndicator();
      } else if (state.status == SearchStatus.error) {
        child = ErrorRetryWidget(
          onPressed: () => context.read<SearchCubit>().loadMoreResults(),
        );
      } else if (!state.canLoadMore) {
        child = const Text('No more results');
      } else {
        child = ElevatedButton(
          onPressed: () => context.read<SearchCubit>().loadMoreResults(),
          child: const Text('More'),
        );
      }

      return Center(
        child: Padding(
          padding: context.insets.paddingS,
          child: child,
        ),
      );
    }

    var isMobile = context.layout == Layout.desktop;
    var padding = isMobile ? context.insets.paddingS : context.insets.paddingM;

    //compute number of columns based on the size of the screen
    //we might want to use a LayoutBuilder to get the actual size that will be available to this widget, not the total size of the screen
    //however the only other widget that takes up width is the nav bar, so this is good enough
    var width = MediaQuery.of(context).size.width - 64;
    int numColumns = max((width / context.appTheme.scale / 400).floor(), 1);

    //if there is more than 1 column use a MasonryGridView, otherwise a ListView
    if (numColumns > 1) {
      return MasonryGridView.builder(
        controller: _scrollController,
        crossAxisSpacing: context.sizes.spaceS,
        mainAxisSpacing: context.sizes.spaceS,
        itemCount: itemCount,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: numColumns,
        ),
        padding: padding,
        itemBuilder: itemBuilder,
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        itemCount: itemCount,
        padding: padding,
        itemBuilder: itemBuilder,
      );
    }
  }
}
