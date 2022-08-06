import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/auth/login/login_screen.dart';
import 'package:flutter_sample/home/home_screen.dart';
import 'package:flutter_sample/routing/error_screen.dart';
import 'package:flutter_sample/settings/settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

/*
TODO
AppRouter could maintain the current stack of AppRoutes (i.e. the current routing state represented by our own typed route objects rather than the string/uri locations used by the go_router package)
that are shown and implement ChangeNotifier to make this information
available to interested listeners, e.g. to track and record analytics about the behaviour of the users.

Updating the information whenever the routes are changed using AppRouter (i.e. using the AppRouter.go or AppRouter.push methods) is easy.
However the routes are usually also changed without involvement of AppRouter, e.g. when the user presses the back button (either in the app or the system back button on some android devices).
To catch these changes we would have to listen to the state of the GoRouter or GoRouterDelegate object.
*/

class AppRouter {
  late final GoRouter _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        name: loginRouteName,
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: homeRouteName,
        path: '/home/:tab',
        builder: (context, state) {
          var p = state.params['tab'] ?? HomeTab.explore.name;
          //TODO how to move to an error page on invalid parameter
          var tab = HomeTab.fromString(p);
          return HomeScreen(key: state.pageKey, tab: tab);
        },
      ),
      GoRoute(
        name: settingsRouteName,
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );

  RouterDelegate<Object> get routerDelegate => _router.routerDelegate;
  RouteInformationParser<Object> get routeInformationParser =>
      _router.routeInformationParser;
  RouteInformationProvider get routeInformationProvider =>
      _router.routeInformationProvider;

  AppRouter();

  void go(AppRoute route) {
    _router.goNamed(route.name,
        params: route.params, queryParams: route.queryParams);
  }

  void push(AppRoute route) {
    _router.pushNamed(route.name,
        params: route.params, queryParams: route.queryParams);
  }

  void close() {
    _router.dispose();
  }
}

/*
For convenience this extension on BuildContext allows us to write:
context.go(LoginRoute()) instead of context.read<AppRouter>().go(LoginRoute())
*/
extension AppRouterHelper on BuildContext {
  void go(AppRoute route) {
    read<AppRouter>().go(route);
  }

  void push(AppRoute route) {
    read<AppRouter>().push(route);
  }
}
