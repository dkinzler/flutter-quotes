import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/app_controller.dart';
import 'package:flutter_sample/auth/auth_cubit.dart';
import 'package:flutter_sample/explore/random_cubit.dart';
import 'package:flutter_sample/favorites/bloc/favorites_cubit.dart';
import 'package:flutter_sample/favorites/bloc/filter_bloc.dart';
import 'package:flutter_sample/routing/routing.dart';
import 'package:flutter_sample/search/search_cubit.dart';
import 'package:flutter_sample/settings/settings_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  final bool useInheritedMediaQuery;
  final Widget Function(BuildContext, Widget?)? builder;
  final Locale? locale;
  final AppController? appController;

  const App({
    Key? key,
    this.useInheritedMediaQuery = false,
    this.builder,
    this.locale,
    this.appController,
  }) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppController _appController;
  AppRouter get _router => _appController.router;

  @override
  void initState() {
    super.initState();
    _appController = widget.appController ?? AppController();
  }

  @override
  Widget build(BuildContext context) {
    var builder = AppTheme.appBuilder;
    if (widget.builder != null) {
      builder = (context, child) {
        return widget.builder!(context, AppTheme.appBuilder(context, child));
      };
    }

    return MultiProvider(
        providers: [
          Provider<AppRouter>.value(value: _appController.router),
          BlocProvider<AuthCubit>.value(value: _appController.authCubit),
          BlocProvider<SearchCubit>.value(value: _appController.searchCubit),
          BlocProvider<RandomCubit>.value(value: _appController.randomCubit),
          BlocProvider<FavoritesCubit>.value(
              value: _appController.favoritesCubit),
          BlocProvider<FilteredFavoritesBloc>.value(
              value: _appController.filterBloc),
          BlocProvider<SettingsCubit>.value(
              value: _appController.settingsCubit),
        ],
        child: MaterialApp.router(
          builder: builder,
          theme: baseTheme,
          routeInformationParser: _router.routeInformationParser,
          routeInformationProvider: _router.routeInformationProvider,
          routerDelegate: _router.routerDelegate,
          locale: widget.locale,
          useInheritedMediaQuery: widget.useInheritedMediaQuery,
        ));
  }
}
