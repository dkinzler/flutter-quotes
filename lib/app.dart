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
          //TODO can we make this lazy somehow, so that only the cubits and stuff that are
          //actually needed are created
          //we could use normal Blocprovider constructor with create() func
          //but this will call close() on the bloc when the provider widget gets out of scope
          //would this be a problem
          //is there another way?
          //alternatively we could create the blocs outside of appController again?
          //but then we have to read them to add them to blocprovider and then
          //the always get created anyway?
          //can we avoid this somehow by also passing a "create/get" func instead of the actual bloc/cubit instances?
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
        child: Builder(builder: (context) {
          var darkMode =
              context.select<SettingsCubit, bool>((c) => c.state.darkMode);
          return MaterialApp.router(
            builder: builder,
            theme: darkMode ? baseThemeDark : baseThemeLight,
            routeInformationParser: _router.routeInformationParser,
            routeInformationProvider: _router.routeInformationProvider,
            routerDelegate: _router.routerDelegate,
            locale: widget.locale,
            useInheritedMediaQuery: widget.useInheritedMediaQuery,
          );
        }));
  }
}
