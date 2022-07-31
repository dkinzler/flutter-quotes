import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/search/actions.dart';
import 'package:flutter_sample/search/search_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/widgets/error.dart';
import 'package:flutter_sample/widgets/quote.dart';

class SliverSearchResultsWidget extends StatelessWidget {
  const SliverSearchResultsWidget({Key? key}) : super(key: key);

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

      return SliverToBoxAdapter(child: Center(child: child));
    }

    //if there are search results, those results will always be shown
    //any loading indicators or error widgets will be shown at the end of the results
    var quotes = state.quotes!;
    if (quotes.isEmpty) {
      return const SliverToBoxAdapter(
          child: Center(child: Text('No results found')));
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

    //TODO what about this padding
    /*
    var isMobile = context.layout == Layout.desktop;
    var padding = isMobile ? context.insets.paddingS : context.insets.paddingM;
    */

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: itemCount,
      ),
    );
  }
}
