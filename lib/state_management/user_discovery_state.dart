part of 'user_discovery_cubit.dart';

@immutable
abstract class UserDiscoveryState {}

class UserDiscoveryInitial extends UserDiscoveryState {}

class UserDiscoveryWaitingForUserInput extends UserDiscoveryState {}

class UserDiscoveryNewQueryLoading extends UserDiscoveryState {}

class UserDiscoveryLoadMoreLoading extends UserDiscoveryState {}

class UserDiscoveryEmptyResult extends UserDiscoveryState {}

class UserDiscoveryResult extends UserDiscoveryState {
  final List<User> result;
  final bool isLast;

  UserDiscoveryResult(this.result, this.isLast);
}

class UserDiscoveryError extends UserDiscoveryState {
  final String message;

  UserDiscoveryError(this.message);
}
