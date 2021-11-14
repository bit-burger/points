part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitialState extends AuthState {}

class LoadingState extends AuthState {}

class LoggedInState extends AuthState {
  final AccountCredentials credentials;

  LoggedInState(this.credentials);
}

class LoggedOutState extends AuthState {}

class AuthErrorState extends LoggedOutState {
  final AuthErrorType type;

  AuthErrorState(this.type);
}
