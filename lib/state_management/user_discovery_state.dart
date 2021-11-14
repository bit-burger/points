part of 'user_discovery_cubit.dart';

class UserResult {
  final User user;
  final bool wasRequested;

  UserResult(this.user, this.wasRequested);
}

@immutable
abstract class UserDiscoveryState {}

class UserDiscoveryWaitingForUserInput extends UserDiscoveryState {}

class UserDiscoveryResult extends UserDiscoveryState {
  final List<UserResult> result;
  final int? nextPage;

  UserDiscoveryResult(this.result, this.nextPage);
}

class UserDiscoveryAwaitingPages extends UserDiscoveryResult {
  UserDiscoveryAwaitingPages() : super([], 0);
}

class UserDiscoveryEmptyResult extends UserDiscoveryState {}

class UserDiscoveryError extends UserDiscoveryState {
  final String message;

  UserDiscoveryError(this.message);
}
