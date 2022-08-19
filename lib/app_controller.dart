import 'dart:async';
import 'package:flutter_quotes/auth/auth_cubit.dart';
import 'package:flutter_quotes/favorites/bloc/bloc.dart';
import 'package:flutter_quotes/favorites/filter/filter.dart';
import 'package:flutter_quotes/explore/random/random_cubit.dart';
import 'package:flutter_quotes/quote/provider.dart';
import 'package:flutter_quotes/routing/routing.dart';
import 'package:flutter_quotes/search/search_cubit.dart';
import 'package:flutter_quotes/settings/settings_cubit.dart';
import 'package:flutter_quotes/tips/bloc/bloc.dart';

class AppController {
  final AuthCubit authCubit = AuthCubit();
  late final AppRouter router = AppRouter(authCubit: authCubit);
  final SearchCubit searchCubit = SearchCubit();

  //TODO do we even need to create this here?
  final RandomCubit randomCubit = RandomCubit();
  final FavoritesCubit favoritesCubit = FavoritesCubit();
  late final FilteredFavoritesBloc filterBloc = FilteredFavoritesBloc(
    favoritesCubit: favoritesCubit,
  );
  final SettingsCubit settingsCubit = SettingsCubit();
  final TipsBloc tipsBloc = TipsBloc();

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

  void _updateQuoteProvider(QuoteProviderType qp) {
    var quoteProvider = QuoteProviderFactory.buildQuoteProvider(qp);
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
