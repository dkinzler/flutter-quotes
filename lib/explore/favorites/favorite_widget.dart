import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/explore/widgets/header.dart';
import 'package:flutter_quotes/favorites/cubit/cubit.dart';
import 'package:flutter_quotes/favorites/model/favorite.dart';
import 'package:flutter_quotes/search/widgets/actions.dart';
import 'package:flutter_quotes/theme/theme.dart';
import 'package:flutter_quotes/widgets/error.dart';
import 'package:flutter_quotes/quote/widgets/quote.dart';

// Shows a single row of quotes selected randomly from the user's favorites.
class FavoritesWidget extends StatelessWidget {
  final int numQuotes;

  const FavoritesWidget({Key? key, required this.numQuotes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var status = context.select<FavoritesCubit, Status>((c) => c.state.status);
    var favorites = context.read<FavoritesCubit>().state.favorites;

    Widget content;
    if (status.isLoading) {
      content = Padding(
        padding: context.insets.paddingM,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (status.isError) {
      content = Padding(
        padding: context.insets.paddingM,
        child: Center(
          child: ErrorRetryWidget(
            onPressed: () => context.read<FavoritesCubit>().reload(),
          ),
        ),
      );
    } else if (favorites.isEmpty) {
      content = Padding(
        padding: context.insets.paddingM,
        child: const Center(
          child: Text('You have not added any quotes to favorites.'),
        ),
      );
    } else {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getRandomFavorites(favorites)
            .map<Widget>(
              (f) => Flexible(
                child: QuoteCard(
                  key: ValueKey(f.id),
                  quote: f.quote,
                  onTagPressed: (String tag) {
                    Actions.invoke<SearchIntent>(
                        context,
                        SearchIntent(
                          gotoSearchScreen: true,
                          query: tag,
                        ));
                  },
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Header(text: 'From your favorites'),
        SizedBox(height: context.sizes.spaceS),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: content,
        ),
      ],
    );
  }

  Iterable<Favorite> _getRandomFavorites(List<Favorite> favorites) {
    var shuffled = List<Favorite>.from(favorites);
    return shuffled.take(numQuotes);
  }
}
