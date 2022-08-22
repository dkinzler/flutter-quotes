import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/bloc/favorite.dart';
import 'package:flutter_quotes/favorites/bloc/favorites_cubit.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/search/actions.dart';
import 'package:flutter_quotes/theme/theme.dart';
import 'package:flutter_quotes/widgets/card.dart';
import 'package:flutter_quotes/widgets/error.dart';
import 'package:flutter_quotes/widgets/quote.dart';

class FavoriteWidget extends StatefulWidget {
  const FavoriteWidget({Key? key}) : super(key: key);

  @override
  State<FavoriteWidget> createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  @override
  Widget build(BuildContext context) {
    var status =
        context.select<FavoritesCubit, LoadingStatus>((c) => c.state.status);
    var favorites = context.read<FavoritesCubit>().state.favorites;

    Widget content;
    if (status == LoadingStatus.loading) {
      content = Padding(
        padding: context.insets.paddingM,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (status == LoadingStatus.error) {
      content = ErrorRetryWidget(
        onPressed: () => context.read<FavoritesCubit>().load(),
      );
    } else {
      Favorite? f;
      if (favorites.isNotEmpty) {
        f = favorites[Random().nextInt(favorites.length)];
      }

      if (f == null) {
        content = Padding(
          padding: context.insets.paddingM,
          child: const Text('You have not added any quotes to favorites'),
        );
      } else {
        content = QuoteWidget(
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
        );
      }
    }

    Widget? trailing;
    if (status == LoadingStatus.loaded) {
      trailing = ElevatedButton(
        key: const ValueKey(AppKey.exploreFavoritesNextButton),
        child: const Text('Another one'),
        onPressed: () {
          //Note: this is kind of a hack
          //calling setState will cause the build function to run again, thus choosing another random quote
          //alternatively we could add a Favorite field to the state of this widget and then
          //recompute another random favorite whenever the button here is pressed
          setState(() {});
        },
      );
    }

    return CustomCard(
      header: Text(
        'From your favorites',
        style: context.theme.textTheme.headlineSmall,
      ),
      content: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: content,
      ),
      trailing: trailing,
    );
  }
}
