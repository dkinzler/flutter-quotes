import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/favorites/add/add_favorite_cubit.dart';
import 'package:flutter_sample/favorites/add/add_favorite_dialog.dart';
import 'package:flutter_sample/favorites/favorite.dart';
import 'package:flutter_sample/favorites/favorites_cubit.dart';

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

class AddFavoriteIntent extends Intent {
  const AddFavoriteIntent();
}

class AddFavoriteAction extends ContextAction<AddFavoriteIntent> {
  final FavoritesCubit favoritesCubit;

  AddFavoriteAction({
    required this.favoritesCubit,
  });

  @override
  Future<void> invoke(AddFavoriteIntent intent, [BuildContext? context]) async {
    if(context != null) {
      await showDialog(
        context: context,
        builder: (context) {
          return BlocProvider<AddFavoriteCubit>(
            create: (context) => AddFavoriteCubit(
              favoritesCubit: favoritesCubit,
            ),
            child: Dialog(child: const AddFavoriteDialog()),
          );
        }
      );
    }
  }
}