part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthLoading extends AuthState {}

class LoggedIn extends AuthState {}

class LoggedOut extends AuthState {}
