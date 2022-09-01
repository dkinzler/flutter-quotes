import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/filter/filter.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/widgets/error.dart';
import 'package:flutter_quotes/quote/widgets/quote.dart';
import 'package:flutter_quotes/favorites/widgets/buttons.dart';

class SliverFavoritesList extends StatelessWidget {
  const SliverFavoritesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = context.watch<FilteredFavoritesBloc>().state;
    var status = state.status;
    var favorites = state.favorites;
    var filteredFavorites = state.filteredFavorites;

    Widget? child;
    if (status.isLoading) {
      child = const CircularProgressIndicator();
    } else if (status.isError) {
      child = ErrorRetryWidget(
        text: 'Ups, something went wrong. Your favorites could not be loaded.',
        key: const ValueKey(AppKey.favoritesErrorRetryWidget),
        onPressed: () => context.read<FilteredFavoritesBloc>().reload(),
      );
    } else if (favorites.isEmpty) {
      child = const Text(
        'You have not favorited any quotes.',
        key: ValueKey(AppKey.favoritesNoFavoritesText),
      );
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
