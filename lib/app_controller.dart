import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sample/auth/auth_cubit.dart';
import 'package:flutter_sample/favorites/favorites_cubit.dart';
import 'package:flutter_sample/favorites/filter_cubit.dart';
import 'package:flutter_sample/quote/mock/apiclient.dart';
import 'package:flutter_sample/quote/quotable/apiclient.dart';
import 'package:flutter_sample/random/random_cubit.dart';
import 'package:flutter_sample/routing/routing.dart';
import 'package:flutter_sample/search/search_cubit.dart';

class AppController {
  final AppRouter router = AppRouter();
  final AuthCubit authCubit = AuthCubit();
  final SearchCubit searchCubit = SearchCubit(
    quoteProvider: MockQuoteApiClient(),
    //quoteProvider: QuotableApiClient(),
  );
  final RandomCubit randomCubit = RandomCubit(
    quoteProvider: MockQuoteApiClient(),
    //quoteProvider: QuotableApiClient(),
  );
  final FavoritesCubit favoritesCubit = FavoritesCubit();
  late final FilterCubit filterCubit = FilterCubit(
    favoritesCubit: favoritesCubit,
  );

  late StreamSubscription _authCubitSubscription;

  AppController() {
    _handleAuthStateChange(authCubit.state);
    _authCubitSubscription = authCubit.stream.listen(_handleAuthStateChange);
  }


  void _handleAuthStateChange(AuthState authState) {
    if(authState.isAuthenticated) {
      router.go(const HomeRoute(tab: HomeTab.search));
    } else {
      router.go(const LoginRoute());
    }
  }

  //TODO do we really need this?
  Future<void> close() async {
    await _authCubitSubscription.cancel();
    router.close();
    await authCubit.close();
    await searchCubit.close();
    await randomCubit.close();
  }
}