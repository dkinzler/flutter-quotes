import 'dart:async';
import 'package:flutter_quotes/auth/auth_cubit.dart';
import 'package:flutter_quotes/favorites/bloc/bloc.dart';
import 'package:flutter_quotes/quote/provider.dart';
import 'package:flutter_quotes/routing/routing.dart';
import 'package:flutter_quotes/search/search_cubit.dart';
import 'package:flutter_quotes/settings/settings_cubit.dart';
import 'package:flutter_quotes/tips/bloc/bloc.dart';

class AppController {
  final bool useMockStorage;

  late final AuthCubit authCubit = AuthCubit(
    loginStore: useMockStorage ? null : HiveLoginStore(),
  );
  late final AppRouter router = AppRouter(authCubit: authCubit);
  final SearchCubit searchCubit = SearchCubit();

  late final FavoritesCubit favoritesCubit = FavoritesCubit(
    storageBuilder: useMockStorage
        ? FavoritesCubit.mockStorageBuilder
        : FavoritesCubit.defaultStorageBuilder,
  );

  final SettingsCubit settingsCubit = SettingsCubit();
  final TipsBloc tipsBloc = TipsBloc();

  late StreamSubscription _authCubitSubscription;

  late StreamSubscription _settingsCubitSubscription;
  Settings? _currentSettings;

  AppController({
    //set this to true for testing, with mock storage no files will be created/no state is persisted after the app is disposed
    this.useMockStorage = false,
  }) {
    _handleAuthStateChange(authCubit.state);
    _authCubitSubscription = authCubit.stream.listen(_handleAuthStateChange);
    _handleSettingsChanged(settingsCubit.state);
    _settingsCubitSubscription =
        settingsCubit.stream.listen(_handleSettingsChanged);
  }

  void _handleAuthStateChange(AuthState authState) {
    if (authState.isAuthenticated) {
      favoritesCubit.init(authState.user.email);
      router.go(const HomeRoute(tab: HomeTab.explore));
    } else {
      //TODO there might be some subtle async issues here
      //e.g. if we logout while some operation to load stuff is still in progress
      //then we might reset the cubit but when the operation finishes it will alter the state
      //it might be easier to create a new cubit instance
      //after every login
      searchCubit.reset();
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
  }

  //TODO do we really need this?
  Future<void> close() async {
    await _authCubitSubscription.cancel();
    await _settingsCubitSubscription.cancel();
    router.close();
    await authCubit.close();
    await searchCubit.close();
  }
}
