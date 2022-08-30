import 'package:equatable/equatable.dart';
import 'package:flutter_quotes/quote/providers/provider.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/*
SettingsCubit keeps and stores app settings:
- dark or light app theme
- the api to use to get quotes
- a ui scaling factor

Not all settings that can be changed on the settings screen are maintained by SettingsCubit.

TODO
Right now the settings are global, i.e. they apply to all users.
It's not hard to adapt this to keep individual settings for each user.
Probably just need to override the "id" getter and rebuild the cubit
whenever a user logs out and a new user in.
*/

class Settings extends Equatable {
  final bool darkMode;
  final QuoteProviderType quoteProvider;
  final double uiScale;

  const Settings({
    this.darkMode = true,
    this.quoteProvider = QuoteProviderType.mock,
    this.uiScale = 1.0,
  });

  @override
  List<Object?> get props => [darkMode, quoteProvider, uiScale];

  Settings copyWith({
    bool? darkMode,
    QuoteProviderType? quoteProvider,
    double? uiScale,
  }) {
    return Settings(
      darkMode: darkMode ?? this.darkMode,
      quoteProvider: quoteProvider ?? this.quoteProvider,
      uiScale: uiScale ?? this.uiScale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'quoteProvider': quoteProvider.name,
      'uiScale': uiScale
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      darkMode: map['darkMode'],
      quoteProvider: QuoteProviderType.fromString(map['quoteProvider']),
      uiScale: map['uiScale'],
    );
  }
}

class SettingsCubit extends HydratedCubit<Settings> {
  SettingsCubit() : super(const Settings());

  void setDarkMode(bool enabled) {
    emit(state.copyWith(darkMode: enabled));
  }

  void setQuoteProvider(QuoteProviderType quoteProvider) {
    emit(state.copyWith(quoteProvider: quoteProvider));
  }

  void setUIScale(double scale) {
    emit(state.copyWith(uiScale: scale));
  }

  @override
  Settings? fromJson(Map<String, dynamic> json) => Settings.fromMap(json);

  @override
  Map<String, dynamic>? toJson(Settings state) => state.toMap();
}
