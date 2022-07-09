import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

enum AuthStatus {unknown, unauthenticated, authenticated}

//TODO have a separate User class that holds email, userId and stuff
class AuthState extends Equatable {
  final AuthStatus status;
  final String email;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  const AuthState({
    required this.status,
    this.email = '',
  });

  const AuthState.unknown() :
    status = AuthStatus.unknown,
    email = '';

  const AuthState.unauthenticated() :
    status = AuthStatus.unauthenticated,
    email = '';

  const AuthState.authenticated({required this.email}) :
    status = AuthStatus.authenticated;
  
  @override
  List<Object?> get props => [status, email];
}


class AuthCubit extends Cubit<AuthState> {
  final _log = Logger('AuthCubit');

  AuthCubit() : super(const AuthState.unknown());

  Future<bool> login({required String email, required String password}) async {
    if(email.isEmpty || password.isEmpty) {
      _log.info('login attempt with empty email or password');
      return false;
    }
    emit(AuthState.authenticated(email: email));
    return true;
  }

  Future<void> logout() async {
    emit(const AuthState.unauthenticated());
  }
}