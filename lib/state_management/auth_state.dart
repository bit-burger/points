part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitialState extends AuthState {}

class LoadingState extends AuthState {}

class LoggedInState extends AuthState {
  final String userId;

  LoggedInState(this.userId);
}

class LoggedOutState extends AuthState {}

class LoggedOutWithErrorState extends LoggedOutState {
  final AuthErrorType type;

  LoggedOutWithErrorState(this.type);
}
