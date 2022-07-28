import 'package:equatable/equatable.dart';
import 'package:flutter_sample/quote/mock/apiclient.dart';
import 'package:flutter_sample/quote/quotable/apiclient.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

//TODO right now these settings are global to the app
//not to each logged in user

enum QuoteProvider {
  mock,
  quotable;

  factory QuoteProvider.fromString(String s) {
    if (s == quotable.name) {
      return quotable;
    } else {
      //return mock even if the given string doesn't match any of the providers
      //alternatively we could also throw an exception if there is no match
      return mock;
    }
  }
}

class Settings extends Equatable {
  final bool darkMode;
  final QuoteProvider quoteProvider;

  const Settings({
    this.darkMode = true,
    this.quoteProvider = QuoteProvider.mock,
  });

  @override
  List<Object?> get props => [darkMode, quoteProvider];

  Settings copyWith({
    bool? darkMode,
    QuoteProvider? quoteProvider,
  }) {
    return Settings(
      darkMode: darkMode ?? this.darkMode,
      quoteProvider: quoteProvider ?? this.quoteProvider,
    );
  }

  Map<String, dynamic> toMap() {
    return {'darkMode': darkMode, 'quoteProvider': quoteProvider.name};
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      darkMode: map['darkMode'],
      quoteProvider: QuoteProvider.fromString(map['quoteProvider']),
    );
  }
}

class SettingsCubit extends HydratedCubit<Settings> {
  SettingsCubit() : super(const Settings());

  void setDarkMode(bool enabled) {
    emit(state.copyWith(darkMode: enabled));
  }

  void setQuoteProvider(QuoteProvider quoteProvider) {
    emit(state.copyWith(quoteProvider: quoteProvider));
  }

  @override
  Settings? fromJson(Map<String, dynamic> json) => Settings.fromMap(json);

  @override
  Map<String, dynamic>? toJson(Settings state) => state.toMap();
}
