import 'dart:async';
import 'package:flutter_sample/auth/auth_cubit.dart';
import 'package:flutter_sample/favorites/bloc/bloc.dart';
import 'package:flutter_sample/explore/random_cubit.dart';
import 'package:flutter_sample/quote/mock/apiclient.dart';
import 'package:flutter_sample/quote/provider.dart' as p;
import 'package:flutter_sample/quote/quotable/apiclient.dart';
import 'package:flutter_sample/routing/routing.dart';
import 'package:flutter_sample/search/search_cubit.dart';
import 'package:flutter_sample/settings/settings_cubit.dart';

class AppController {
  final AppRouter router = AppRouter();
  final AuthCubit authCubit = AuthCubit();
  final SearchCubit searchCubit = SearchCubit();
  final RandomCubit randomCubit = RandomCubit();
  final FavoritesCubit favoritesCubit = FavoritesCubit();
  late final FilteredFavoritesBloc filterBloc = FilteredFavoritesBloc(
    favoritesCubit: favoritesCubit,
  );
  final SettingsCubit settingsCubit = SettingsCubit();

  late StreamSubscription _authCubitSubscription;

  late StreamSubscription _settingsCubitSubscription;
  Settings? _currentSettings;

  AppController() {
    _handleAuthStateChange(authCubit.state);
    _authCubitSubscription = authCubit.stream.listen(_handleAuthStateChange);
    _handleSettingsChanged(settingsCubit.state);
    _settingsCubitSubscription =
        settingsCubit.stream.listen(_handleSettingsChanged);
  }

  void _handleAuthStateChange(AuthState authState) {
    if (authState.isAuthenticated) {
      favoritesCubit.init(authState.user.email);
      randomCubit.init();
      router.go(const HomeRoute(tab: HomeTab.explore));
    } else {
      //TODO there might be some subtle async issues here
      //e.g. if we logout while some operation to load stuff is still in progress
      //then we might reset the cubit but when the operation finishes it will alter the state
      //it might be easier to create a new cubit instance
      //after every login
      searchCubit.reset();
      randomCubit.reset();
      favoritesCubit.reset();
      router.go(const LoginRoute());
    }
  }

  void _handleSettingsChanged(Settings settings) {
    if (_currentSettings != null) {
      if (_currentSettings!.quoteProvider != settings.quoteProvider) {
        _updateQuoteProvider(settings.quoteProvider);
      }
    } else {
      _updateQuoteProvider(settings.quoteProvider);
    }
    _currentSettings = settings;
  }

  void _updateQuoteProvider(QuoteProvider qp) {
    p.QuoteProvider quoteProvider;
    if (qp == QuoteProvider.quotable) {
      quoteProvider = QuotableApiClient();
    } else {
      quoteProvider = MockQuoteApiClient();
    }
    searchCubit.init(quoteProvider);
    randomCubit.init(quoteProvider: quoteProvider);
  }

  //TODO do we really need this?
  Future<void> close() async {
    await _authCubitSubscription.cancel();
    await _settingsCubitSubscription.cancel();
    router.close();
    await authCubit.close();
    await searchCubit.close();
    await randomCubit.close();
  }
}
