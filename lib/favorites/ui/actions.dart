import 'package:flutter/material.dart';
import 'package:flutter_sample/favorites/bloc/favorite.dart';
import 'package:flutter_sample/favorites/bloc/favorites_cubit.dart';

class DeleteFavoriteIntent extends Intent {
  final Favorite favorite;

  const DeleteFavoriteIntent({
    required this.favorite,
  });
}

class DeleteFavoriteAction extends ContextAction<DeleteFavoriteIntent> {
  final FavoritesCubit favoritesCubit;

  DeleteFavoriteAction({
    required this.favoritesCubit,
  });

  @override
  Future<void> invoke(DeleteFavoriteIntent intent, [BuildContext? context]) async {
    favoritesCubit.removeById(intent.favorite.id);
    if(context != null) {
      var scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      scaffoldMessenger?.hideCurrentSnackBar();
      scaffoldMessenger?.showSnackBar(
        SnackBar(
          content: const Text('Favorite deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              favoritesCubit.add(intent.favorite.quote);
            },
          ),
          duration: const Duration(seconds :6),
        ),
      );
    }
  }
}