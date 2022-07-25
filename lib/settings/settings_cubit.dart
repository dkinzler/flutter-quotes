import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

//TODO right now these settings are global to the app
//not to each logged in user

class Settings extends Equatable {
  final bool darkMode;

  const Settings({
    this.darkMode = true,
  });

  @override
  List<Object?> get props => [darkMode];

  Settings copyWith({
    bool? darkMode,
  }) {
    return Settings(
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      darkMode: map['darkMode'],
    );
  }
}

class SettingsCubit extends HydratedCubit<Settings> {
  SettingsCubit() : super(const Settings());

  void setDarkMode(bool enabled) {
    emit(state.copyWith(darkMode: enabled));
  }

  @override
  Settings? fromJson(Map<String, dynamic> json) => Settings.fromMap(json);

  @override
  Map<String, dynamic>? toJson(Settings state) => state.toMap();
}
