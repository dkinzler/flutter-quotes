import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/app_controller.dart';
import 'package:flutter_quotes/routing/routing.dart';
import 'package:flutter_quotes/settings/settings_cubit.dart';
import 'package:flutter_quotes/theme/theme.dart';
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
          BlocProvider.value(value: _appController),
          Provider.value(value: _appController.router),
          RepositoryProvider.value(value: _appController.authRepository),
          BlocProvider.value(value: _appController.settingsCubit),
          BlocProvider.value(value: _appController.tipsBloc),
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
