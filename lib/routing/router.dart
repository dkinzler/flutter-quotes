import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quotes/auth/login/login_screen.dart';
import 'package:flutter_quotes/auth/repository/repository.dart';
import 'package:flutter_quotes/home/home_screen.dart';
import 'package:flutter_quotes/routing/error_screen.dart';
import 'package:flutter_quotes/settings/settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

/*
Routing in this app is based on the go_router package.
We use subclasses of AppRoute to navigate in a type-safe way.
I.e. instead of relying on location strings, e.g. context.go('/example?x=y')),
we can write context.go(ExampleRoute(x: 'y')).
That way we can already catch errors like missing parameters/wrong parameter types/... 
at compile time.

In future updates go_router will probably support typed routing out of the box,
so we won't need this custom solution anymore.
*/

/*
AppRouter wraps an instance of GoRouter to provide type-safe routing.

TODO
AppRouter could maintain the current stack of AppRoutes (i.e. the current routing state represented by our own typed route objects rather than the string/uri locations used by the go_router package)
that are shown and implement ChangeNotifier to make this information
available to interested listeners, e.g. to track and record analytics about the behaviour of the users.

Updating the information whenever the routes are changed using AppRouter (i.e. using the AppRouter.go or AppRouter.push methods) is easy.
However the routes are usually also changed without involvement of AppRouter, e.g. when the user presses the back button (either in the app or the system back button on some android devices).
To catch these changes we would have to listen to the state of the GoRouter or GoRouterDelegate object.
*/
class AppRouter {
  //need auth cubit to check if a user is logged in or not, and if not prevent them from accessing certain routes
  final AuthRepository? authRepository;

  late final GoRouter _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        name: loginRouteName,
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        redirect: (state) {
          //will prevent users from accessing the login screen if they are logged in
          //this is mostly for web, where the user could manually change the url to /login
          if (authRepository != null) {
            if (!authRepository!.user.isEmpty) {
              var route = const HomeRoute(tab: HomeTab.explore);
              return state.namedLocation(
                route.name,
                params: route.params,
                queryParams: route.queryParams,
              );
            }
          }
          return null;
        },
      ),
      GoRoute(
        name: homeRouteName,
        path: '/home/:tab',
        builder: (context, state) {
          var p = state.params['tab'] ?? HomeTab.explore.name;
          var tab = HomeTab.fromString(p);
          return HomeScreen(key: state.pageKey, tab: tab);
        },
        redirect: (state) {
          //will prevent users from accessing the home screen if they are not logged in
          //this is mostly for web, where the user could manually change the url to e.g. /home/explore
          if (authRepository != null) {
            if (authRepository!.user.isEmpty) {
              var route = const LoginRoute();
              return state.namedLocation(
                route.name,
                params: route.params,
                queryParams: route.queryParams,
              );
            }
          }
          return null;
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

  AppRouter({this.authRepository});

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
