import 'package:equatable/equatable.dart';

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
