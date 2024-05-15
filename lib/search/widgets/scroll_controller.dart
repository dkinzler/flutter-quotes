import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quotes/search/cubit/search_cubit.dart';

/*
A ScrollController that automatically loads more results when the user reaches the end of a Scrollable.
*/
class InfiniteScrollController extends ScrollController {
  final SearchCubit searchCubit;
  // value between 0 and 1 that determines when to trigger an operation to load more results
  // e.g. if value=0.9 then a load operation will be triggered when the user has scrolled down 90% of the way
  final double trigger;

  InfiniteScrollController({
    required this.searchCubit,
    this.trigger = 0.9,
  }) {
    addListener(_autoLoadMore);
  }

  bool _loadInProgress = false;
  Future<void> _autoLoadMore() async {
    if (!_loadInProgress &&
        (position.pixels > 0.9 * position.maxScrollExtent ||
            // this is to catch the situation when initially all the search results already fit on screen
            // in this case extentAfter will be 0 or very small
            position.extentAfter < 0.1 * position.viewportDimension)) {
      _loadInProgress = true;
      await searchCubit.loadMoreResults();
      _loadInProgress = false;
    }
  }

  // initially we only load a certain number of results
  // on a larger screen, all the results might already fit on screen
  // so we should immediately load more results
  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    SchedulerBinding.instance.addPostFrameCallback((_) => _autoLoadMore());
  }

  @override
  void dispose() {
    removeListener(_autoLoadMore);
    super.dispose();
  }
}
