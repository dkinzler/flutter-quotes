import 'package:equatable/equatable.dart';

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

abstract class AppRoute extends Equatable {
  String get name;
  Map<String, String> get params => const {};
  Map<String, String> get queryParams => const {};

  const AppRoute();

  @override
  List<Object?> get props => [params, queryParams];
}

const loginRouteName = 'login';

class LoginRoute extends AppRoute {
  const LoginRoute();

  @override
  String get name => loginRouteName;
}

const homeRouteName = 'home';

enum HomeTab {
  explore,
  search,
  favorites;

  static HomeTab fromString(String s) {
    if (s == search.name) {
      return search;
    } else if (s == favorites.name) {
      return favorites;
    } else {
      return explore;
    }
  }
}

class HomeRoute extends AppRoute {
  final HomeTab tab;

  const HomeRoute({
    required this.tab,
  });

  @override
  Map<String, String> get params => {'tab': tab.name};

  @override
  String get name => homeRouteName;
}

const settingsRouteName = 'settings';

class SettingsRoute extends AppRoute {
  const SettingsRoute();

  @override
  String get name => settingsRouteName;
}
