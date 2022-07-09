import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/auth/login/login_screen.dart';
import 'package:flutter_sample/home/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

//TODO explain this better, is this actually necessary, it wasn't below for HomeScreen
//maybe only if we use page builders instead of widget builders?
/*
Note for page builders:
  Whenever we create a some page that takes parameters, we should provide a key that is different
  for different parameters. Because otherwise when the new page is pusehd, the page widget isn't actually rebuild.
  Because without a key, flutter doesn't rebuild the widget when the type of widget is the same.
  E.g. we have path '/somepath' with builder 
    (context, state) {
      var x = state.queryParams['xyz'];
      return SomePage(x: x);
    }
  if we are already on SomePage with x='somestring' 
  and then push SomePage with x='someotherstring', the ui won't actually update
*/

/*
TODO
AppRouter could implement ChangeNotifier and internally listen to _router or _routerDelegate
whenever location changes we can parse the location back into an AppPage object
this allows us to listen to AppPage changes
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
          var p = state.params['tab'] ?? HomeTab.search.name;
          //TODO how to move to an error page on invalid parameter
          var tab = HomeTab.fromString(p);
          return HomeScreen(key: state.pageKey, tab: tab);
        },
      ),
    ],
    //TODO make error page
    //Override to use a custom ErrorPage
    //error page might be shown if we try to navigate to an undefined location
    //errorBuilder: (context, state) => const ErrorPage(),
  );

  RouterDelegate<Object> get routerDelegate => _router.routerDelegate;
  RouteInformationParser<Object> get routeInformationParser => _router.routeInformationParser;
  RouteInformationProvider get routeInformationProvider => _router.routeInformationProvider;


  AppRouter();

  void go(AppRoute appRoute) {
    _router.goNamed(appRoute.name, params: appRoute.params, queryParams: appRoute.queryParams);
  }

  void close() {
    _router.dispose();
  }
}

extension AppRouterHelper on BuildContext {
  void go(AppRoute appRoute) {
    read<AppRouter>().go(appRoute);
  }
}
