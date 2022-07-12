import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_sample/auth/auth_cubit.dart';

enum LoginResult {success, error}

class LoginState extends Equatable {
  final bool loginInProgress;
  final LoginResult? loginResult;

  final String username;
  final String password;

  const LoginState({
    this.loginInProgress = false,
    this.loginResult,
    this.username = '',
    this.password = '',
  });

  @override
  List<Object?> get props => [loginInProgress, loginResult, username, password];

  LoginState copyWith({
    bool? loginInProgress,
    LoginResult? loginResult,
    String? username,
    String? password,
  }) {
    return LoginState(
      loginInProgress: loginInProgress ?? this.loginInProgress,
      loginResult: loginResult ?? this.loginResult,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  final AuthCubit authCubit;

  LoginCubit({
    required this.authCubit,
  }) : super(const LoginState());

  Future<bool> login() async {
    if(state.loginInProgress) {
      return false;
    }

    var username = state.username;
    var password = state.password;
    if(username.isEmpty || password.isEmpty) {
      return false;
    }

    emit(state.copyWith(loginInProgress: true, loginResult: null));
    await Future.delayed(const Duration(seconds: 2));
    var success = await authCubit.login(email: username, password: password);
    if(success) {
      emit(state.copyWith(loginInProgress: false, loginResult: LoginResult.success));
      return true;
    } else {
      emit(state.copyWith(loginInProgress: false, loginResult: LoginResult.error));
      return false;
    }
  }

  void setUsername(String username) {
    emit(state.copyWith(username: username));
  }

  void setPassword(String password) {
    emit(state.copyWith(password: password));
  }
}