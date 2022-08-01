import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/search/search_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';

class SearchResultHeader extends StatelessWidget {
  const SearchResultHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = context.watch<SearchCubit>().state;
    if (state.quotes?.isNotEmpty ?? false) {
      var query = state.query;
      var numResults = state.totalNumberOfResults;
      String text;
      if (numResults != null) {
        text = '$numResults results found for \'$query\'';
      } else {
        text = 'Showing results for \'$query\'';
      }
      return Padding(
        padding: context.insets.paddingM,
        child: Text(text),
      );
    }
    return const SizedBox.shrink();
  }
}
