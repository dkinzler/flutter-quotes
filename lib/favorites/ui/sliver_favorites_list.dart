import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/bloc/bloc.dart';
import 'package:flutter_quotes/favorites/filter/filter.dart';
import 'package:flutter_quotes/widgets/error.dart';
import 'package:flutter_quotes/widgets/quote.dart';
import 'package:flutter_quotes/widgets/quote_buttons.dart';

class SliverFavoritesList extends StatelessWidget {
  const SliverFavoritesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var status =
        context.select<FavoritesCubit, LoadingStatus>(((c) => c.state.status));
    var state = context.watch<FilteredFavoritesBloc>().state;
    var favorites = state.favorites;
    var filteredFavorites = state.filteredFavorites;

    Widget? child;
    if (status == LoadingStatus.loading) {
      child = const CircularProgressIndicator();
    } else if (status == LoadingStatus.error) {
      child = ErrorRetryWidget(
        onPressed: () => context.read<FavoritesCubit>().load(),
      );
    } else if (favorites.isEmpty) {
      child = const Text('You have not favorited any quotes.');
    }

    if (child != null) {
      return SliverToBoxAdapter(
        child: Center(child: child),
      );
    }

    itemBuilder(BuildContext context, int index) {
      var favorite = filteredFavorites[index];
      return QuoteCard(
        quote: favorite.quote,
        button: DeleteFavoriteButton(
          favorite: favorite,
        ),
        onTagPressed: (String tag) {
          context.read<FilteredFavoritesBloc>().add(FilterTagAdded(tag: tag));
        },
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: filteredFavorites.length,
      ),
    );
  }
}
