import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/app_controller.dart';
import 'package:flutter_sample/auth/auth_cubit.dart';
import 'package:flutter_sample/favorites/bloc/bloc.dart';
import 'package:flutter_sample/explore/random_cubit.dart';
import 'package:flutter_sample/routing/routing.dart';
import 'package:flutter_sample/search/search_cubit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'logging.dart';
import 'app.dart';

Future<void> main() async {
  return runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      initLogging();
      await Hive.initFlutter();
      //TODO explain here why we insert AppRouter into tree
      var appController = AppController();
      runApp(
        MultiProvider(providers: [
          Provider<AppRouter>.value(value: appController.router),
          BlocProvider<AuthCubit>.value(value: appController.authCubit),
          BlocProvider<SearchCubit>.value(value: appController.searchCubit),
          BlocProvider<RandomCubit>.value(value: appController.randomCubit),
          BlocProvider<FavoritesCubit>.value(
              value: appController.favoritesCubit),
          BlocProvider<FilteredFavoritesBloc>.value(
              value: appController.filterBloc),
        ], child: const App()),
      );
      //TODO set error logging function here, also set FlutterError.onError
    },
    (error, stack) {},
  );
}
