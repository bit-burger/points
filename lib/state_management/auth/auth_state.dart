part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitialState extends AuthState {}

class LoadingAuth extends AuthState {}

class LoggedInState extends AuthState {
  final AccountCredentials credentials;

  LoggedInState(this.credentials);
}

/// If logged in, but a connection error is recorded by another cubit
class LoggedInPausedOnConnectionError extends AuthState {
  final bool retrying;
  LoggedInPausedOnConnectionError({this.retrying = false}) : super();
}

class LoggedOutState extends AuthState {
  final AuthErrorType? logInError;

  LoggedOutState([this.logInError]);
}
