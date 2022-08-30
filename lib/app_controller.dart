import 'dart:async';
import 'package:flutter_quotes/auth/model/user.dart';
import 'package:flutter_quotes/auth/repository/repository.dart';
import 'package:flutter_quotes/auth/repository/storage.dart';
import 'package:flutter_quotes/favorites/cubit/cubit.dart';
import 'package:flutter_quotes/favorites/repository/favorites_repository.dart';
import 'package:flutter_quotes/favorites/repository/storage/favorites_storage.dart';
import 'package:flutter_quotes/quote/providers/provider.dart';
import 'package:flutter_quotes/quote/repository/repository.dart';
import 'package:flutter_quotes/routing/routing.dart';
import 'package:flutter_quotes/search/search_cubit.dart';
import 'package:flutter_quotes/settings/settings_cubit.dart';
import 'package:flutter_quotes/tips/bloc/bloc.dart';

class AppController {
  final bool useMockStorage;

  late final AuthRepository authRepository = AuthRepository(
    loginStore: useMockStorage ? null : HiveLoginStore(),
  );
  late final QuoteRepository quoteRepository = QuoteRepository();
  late final favoritesRepository = FavoritesRepository(
    storageType:
        useMockStorage ? FavoritesStorageType.mock : FavoritesStorageType.hive,
  );

  late final AppRouter router = AppRouter(authRepository: authRepository);

  late final SearchCubit searchCubit =
      SearchCubit(quoteRepository: quoteRepository);
  late final FavoritesCubit favoritesCubit = FavoritesCubit(
    favoritesRepository: favoritesRepository,
  );
  final SettingsCubit settingsCubit = SettingsCubit();
  final TipsBloc tipsBloc = TipsBloc();

  late StreamSubscription _authRepositorySubscription;
  late StreamSubscription _settingsCubitSubscription;
  Settings? _currentSettings;

  AppController({
    //set this to true for testing, with mock storage no files will be created/no state is persisted after the app is disposed
    this.useMockStorage = false,
  }) {
    _authRepositorySubscription =
        authRepository.currentUser.listen(_handleAuthUserChanged);
    _handleSettingsChanged(settingsCubit.state);
    _settingsCubitSubscription =
        settingsCubit.stream.listen(_handleSettingsChanged);
  }

  void _handleAuthUserChanged(User user) {
    if (!user.isEmpty) {
      favoritesRepository.init(user.email);
      router.go(const HomeRoute(tab: HomeTab.explore));
    } else {
      //TODO there might be some subtle async issues here
      //e.g. if we logout while some operation to load stuff is still in progress
      //then we might reset the cubit but when the operation finishes it will alter the state
      //it might be easier to create a new cubit instance
      //after every login
      searchCubit.reset();
      favoritesRepository.reset();
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
    quoteRepository.changeProvider(qp);
    searchCubit.reset();
  }

  //TODO do we really need this?
  Future<void> close() async {
    await _authRepositorySubscription.cancel();
    await _settingsCubitSubscription.cancel();
    router.close();
    await authRepository.close();
    await searchCubit.close();
  }
}
