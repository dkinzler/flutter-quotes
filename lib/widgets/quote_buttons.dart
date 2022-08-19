import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/favorites/bloc/favorite.dart';
import 'package:flutter_quotes/favorites/bloc/favorites_cubit.dart';
import 'package:flutter_quotes/favorites/ui/actions.dart';
import 'package:flutter_quotes/quote/quote.dart';

class QuoteFavoriteButton extends StatelessWidget {
  final Quote quote;
  final double? iconSize;

  const QuoteFavoriteButton({
    Key? key,
    required this.quote,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isFavorited = context
        .select<FavoritesCubit, bool>((c) => c.state.containsQuote(quote));
    return IconButton(
      splashRadius: iconSize != null ? iconSize! + 8 : null,
      icon: Icon(
        isFavorited ? Icons.favorite : Icons.favorite_border,
        color: Colors.pink.shade700,
        size: iconSize,
      ),
      onPressed: () {
        context.read<FavoritesCubit>().toggle(quote);
      },
    );
  }
}

class DeleteFavoriteButton extends StatelessWidget {
  final Favorite favorite;
  final double? iconSize;

  const DeleteFavoriteButton({
    Key? key,
    required this.favorite,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: iconSize != null ? iconSize! + 8 : null,
      icon: Icon(
        Icons.delete,
        size: iconSize,
      ),
      onPressed: () {
        Actions.invoke<DeleteFavoriteIntent>(
            context,
            DeleteFavoriteIntent(
              favorite: favorite,
            ));
      },
    );
  }
}
