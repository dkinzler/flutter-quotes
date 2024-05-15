import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_quotes/auth/repository/auth_repository.dart';

/*
LoginCubit manages the login form state, which consists of the following:
- the currently entered email and password
  this is kept in sync with the UI e.g. by using the setEmail/setPassword methods in the onChanged callback on TextField widgets
- whether or not a login is in progress (i.e. the user pressed the login button and is waiting for the result)
  if a login is in progress we might show a progress indicator in the UI instead of the login button
- the result of the latest login attempt if any
  if the last login attempt failed, we might e.g. show an error message in the UI

Note:
For a simple form like this we could just manage the form state directly
in a StatefulWidget.
However, especially for more complicated forms, it is a good idea to separate
the form state from the UI code. E.g. we can separately test the LoginCubit and any UI code using it.

For more complicated forms we could also use a package like reactive_forms to more easily keep
the cubit state in sync with the values entered in the UI.
*/

class LoginState extends Equatable {
  final bool loginInProgress;
  final LoginResult? loginResult;

  final String email;
  final String password;

  const LoginState({
    this.loginInProgress = false,
    this.loginResult,
    this.email = '',
    this.password = '',
  });

  @override
  List<Object?> get props => [loginInProgress, loginResult, email, password];

  LoginState copyWith({
    bool? loginInProgress,
    LoginResult? loginResult,
    String? email,
    String? password,
  }) {
    return LoginState(
      loginInProgress: loginInProgress ?? this.loginInProgress,
      loginResult: loginResult ?? this.loginResult,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  LoginCubit({
    required this.authRepository,
  }) : super(const LoginState());

  void setEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void setPassword(String password) {
    emit(state.copyWith(password: password));
  }

  void resetResult() {
    // need to do this manually, since passing null as an optional parameter doesn't work (i.e. state.copyWith(loginResult: null))
    emit(LoginState(
      email: state.email,
      password: state.password,
      loginInProgress: state.loginInProgress,
      loginResult: null,
    ));
  }

  Future<void> login() async {
    // don't allow multiple login attempts to run at once
    if (state.loginInProgress) {
      return;
    }

    var email = state.email;
    var password = state.password;
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    emit(LoginState(
      loginInProgress: true,
      loginResult: null,
      email: state.email,
      password: state.password,
    ));
    // add an artifical delay to test the UI
    // e.g. while the login attempt is in progress a progress indicator might be shown
    await Future.delayed(const Duration(seconds: 1));
    var result = await authRepository.login(email: email, password: password);
    emit(state.copyWith(loginInProgress: false, loginResult: result));
  }
}
