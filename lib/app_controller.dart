import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/auth/model/user.dart';
import 'package:flutter_quotes/auth/repository/auth_repository.dart';
import 'package:flutter_quotes/auth/repository/storage.dart';
import 'package:flutter_quotes/favorites/repository/storage/favorites_storage.dart';
import 'package:flutter_quotes/routing/routing.dart';
import 'package:flutter_quotes/settings/settings_cubit.dart';
import 'package:flutter_quotes/tips/bloc/bloc.dart';

/*
App Architecture
----------------

The components of this app can be thought of as belonging to different layers:
(see https://bloclibrary.dev/#/architecture which serves as the basis for this app)

* Data providers
  - retrieves/manipulates "raw" data, usually provides simple methods to create/save/delete/load/query/search data
  - "raw" data means that the data might not be in a format that is usable/convenient for the app, it needs to be further processed 
    until it reaches the user's screen
  - examples: 
    - a client for a quotes API provides data obtained over the network (see e.g. QuotableApiClient in this app)
    - a storage class that loads/persists data to disk (see e.g. FavoritesStorage)

* Repositories
  - a repository is an intermediary between the application/ui layer of the app and the data sources, abstracts away
    the details of using individual data providers
  - it can combine multiple data providers into a single data source, transform the data into a consistent format, ...
  - decouples the application/ui layer from the data providers, can implement a repository in such a way, that it is
    e.g. possible to switch from one quotes API to another, without the application layer noticing/being involved 
    and without having to recreate the repository
  - examples in this app: AuthRepository, FavoritesRepository, QuotesRepository

* Business logic
  - the components of the business logic layer are typically Blocs/Cubits
    they mediate between the data layer (repositories) and the UI/presentation layer
  - usually a Bloc/Cubit will depend on a repository (received in the constructor of the Bloc/Cubit) to get data
  - it might transform the data from the repository into the final format that is needed in the UI, this can e.g. also include
    filtering/sorting the data
  - receives input/user actions from the UI layer
      * some actions can be handled completely in the Bloc/Cubit, e.g. if the user changes the sort order of a list of data objects the Bloc/Cubit manages
      * other actions, e.g. to add or delete a data object, the Bloc/Cubit will pass on to the repository
  - i.e. the UI/presentation layer (usually) doesn't interact with the data layer (i.e. repositories) directly, but through the business logic layer (i.e Blocs/Cubits)
    e.g. in this app, when a user wants to favorite a quote, the UI layer will call the add() method on FavoritesCubit and FavoritesCubit will call FavoritesRepository 
    to actually save the favorite

* UI/presentation layer
  - displays the data from Blocs/Cubits
  - uses the Blocs/Cubits to implement user input/actions


The approach above is a general guideline, sometimes it can make sense to deviate and cut some corners.
E.g. in this app we use a SettingsCubit to manage and persist app settings (dark mode, ui scaling, what quote api to use, ...).
SettingsCubit is a HydratedCubit, that automatically persists its state to disk, i.e. SettingsCubit is a business layer component that interacts with
UI/presentation layer but is also its own data provider/repository.
We could implement the settings feature by using a separate SettingsRepository and then maybe a SettingsStorage data provider, but this would introduce
a lot of code and boilerplate to just achieve the same simple feature.
Right now the settings of the app are global, they apply to all users. If in the future we would want to provide separate settings for each user, it might then make 
sense to introduce a SettingsRepository.


When and where to create dependencies
-------------------------------------
(These are some thoughts about where and when to create dependencies like Blocs/Cubits/Repositories, the pros, cons, possible problems and things to consider
with different approaches. Might be interesting for future reference, when similar questions come up in another project.)

There are different approaches to creating repositories/blocs/cubits:

- Create them locally, where they are needed
  * Consider e.g. a search for quotes feature:
    - There is a SearchScreen widget that displays the search results managed by SearchCubit.
    - We would create SearchCubit directly above SearchScreen in the widget tree, in the route for SearchScreen.
    - Whenever we navigate to another page/screen in the app, SearchCubit will be destroyed.
    - Having SearchCubit around only when necessary saves memory.
    - However when we navigate to another screen, the state of SearchCubit will be lost, i.e. if we
      go back to SearchScreen the previous search results will no longer be shown.
    - This can be avoided by e.g. making SearchCubit a HydratedCubit that persists its state and loads it back
      every time a new instance is created. But this will introduce a delay when creating the cubit, that is probably
      noticeable in the UI. There is a small delay when opening the SearchScreen until the old search results are shown.

- Create them globally
  * Repositories/blocs/cubits will only be created once on app startup.
  * We might need to reinitialize/reset them. E.g. when a user logs out and another user logs in, we need to make sure FavoritesRepository doesn't make the favorites of the
    old user available to the new one. This requires extra code and coordination, e.g. init() and reset() methods on repositories/blocs/cubit
    and a component that calls these methods when appropriate, e.g. when the auth state of the app changes.
    Although it could be argued that this is a good thing, because preventing one user from seeing another user's favorites now becomes an explicit thing,
    that is documented in code.
  * State is persisted across navigation, e.g. if SearchCubit is global and we change from the SearchScreen to the FavoritesScreen and back, the previous
    search results will still be shown.
  * Sometimes it is convenient to have global access to all the different dependencies, we could e.g. have a class AppController
    that on app startup creates all the different repositories/blocs/cubits. Consider the following example from this app:
      In the app settings we can choose which quotes API to use to search for quotes. Whenever this setting changes, we need
      to inform QuoteRepository, so that it can use the correct data provider.
      If we have global access to both SettingsCubit and QuoteRepository in the AppController class, we can implement this coordination there.
      In fact any coordination between components can probably be implemented there, in a central place where it is easy to find.
      If we created the dependencies locally, we would probably have to insert a BlocListener somewhere in the widget tree. The BlocListener would listen
      to changes in SettingsCubit and when the quote API setting changes, call a method on QuoteRepository to change the quote provider.
      But now this coordination between SettingsCubit and QuoteRepository is in code located somewhere among UI/presentation layer code, where it doesn't really belong.
      One might argue that usually this coordination can be avoided in the first place by setting up the dependencies correctly, but this in itself
      will often involve a tradeoff that might e.g. introduce a lot of additional code.
  * Creating all dependencies globally might have some performance and memory impact,
    although in this app the cubit states will be very small, e.g. just a list of quotes/text.
  * Creating e.g. a Bloc globally and then resetting/reinitializing it when a new user logs in
    might produce some subtle issues with asynchronous operations.
    E.g. if we logout while some async operation (e.g. a network request to load some data) is still in progress,
    we will reset the cubit state and then the async operation will finish and change the state.
    Although this scenario is not that likely, it is still something to be considered, especially if there are async operations that typically take a couple of seconds to complete.
    This problem doesn't arise when we create a new Bloc instance every time a new user logs in.

- Not globally, but available across app routes/pages/screens
  * If we use nested routes (as in this app) we might have a home route/HomeScreen widget that shows the app scaffold (app bar, maybe a bottom navigation bar or navigation rail) while the body
    of the widget is used to show the different screens of the app. As soon as a user logs in the HomeScreen will be shown and it will remain there until the user logs out.
  * To make a Bloc or Cubit available to multiple screens/routes of the app, we can then create these dependencies directly above the HomeScreen widget.
    However these are not global, when the user logs out they will be disposed and when a new user logs in, new instances of the Blocs/Cubits will be created.

As discussed, there are pros and cons to all the approaches. For this app we decided to have:
- Some global dependencies, e.g. AuthRepository, SettingsCubit and TipsBloc, they are created only once on app startup.
- Some local dependencies, e.g. the FilteredFavoritesBloc that can be used to search/filter/sort the set of favorite quotes of a user.
  Every time we navigate to the favorites screen/tab a new instance of this bloc is created.
- FavoritesRepository, QuoteRepository, FavoritesCubit and SearchCubit are inserted above the HomeScreen, and therefore available across the three routes/tabs (explore/search/favorites) of the app.
  They will be recreated every time a user logs out and a new user logs back in.
*/

/*
AppController is a cubit that makes the current authentication state and some other properties available to the app.
It is also the place to implement app-global coordination tasks. E.g. AppController listens to AuthRepository for changes in the
authentication state. If a user logs in or a user logs out AppController will change the route of the app.
*/
class AppState extends Equatable {
  //set this to true for testing, with mock storage no files will be created/no state is persisted after the app is disposed
  final bool useMockStorage;
  FavoritesStorageType get favoritesStorageType =>
      useMockStorage ? FavoritesStorageType.mock : FavoritesStorageType.hive;

  //the current user or User.empty if no user is logged in
  final User user;
  bool get isUnauthenticated => user == User.empty;
  bool get isAuthenticated => !isUnauthenticated;

  const AppState({
    this.useMockStorage = false,
    this.user = User.empty,
  });

  @override
  List<Object?> get props => [useMockStorage, user];

  AppState copyWith({
    bool? useMockStorage,
    User? user,
  }) {
    return AppState(
      useMockStorage: useMockStorage ?? this.useMockStorage,
      user: user ?? this.user,
    );
  }
}

class AppController extends Cubit<AppState> {
  late final authRepository = AuthRepository(
    loginStore: state.useMockStorage ? null : HiveLoginStore(),
  );

  late final AppRouter router = AppRouter(authRepository: authRepository);

  late final settingsCubit = SettingsCubit();
  late final TipsBloc tipsBloc = TipsBloc();

  AppController({
    bool useMockStorage = false,
  }) : super(AppState(useMockStorage: useMockStorage)) {
    init();
  }

  StreamSubscription? _authRepositorySubscription;

  void init() {
    _authRepositorySubscription =
        authRepository.currentUser.listen(_handleAuthUserChanged);
  }

  void _handleAuthUserChanged(User user) {
    emit(state.copyWith(user: user));
    if (!user.isEmpty) {
      router.go(const HomeRoute(tab: HomeTab.explore));
    } else {
      router.go(const LoginRoute());
    }
  }

  @override
  Future<void> close() async {
    await _authRepositorySubscription?.cancel();
    router.close();
    await authRepository.close();
    return super.close();
  }
}
