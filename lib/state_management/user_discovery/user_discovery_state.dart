part of 'user_discovery_cubit.dart';

@immutable
abstract class UserDiscoveryState {}

class UserDiscoveryWaitingForUserInput extends UserDiscoveryState {}

class UserDiscoveryResult extends UserDiscoveryState {
  final List<User> users;
  final Set<String> invitedUserIds;
  final int? nextPage;

  UserDiscoveryResult(this.users, this.invitedUserIds, this.nextPage);
}

class UserDiscoveryAwaitingPages extends UserDiscoveryResult {
  UserDiscoveryAwaitingPages() : super([], {}, 0);
}

class UserDiscoveryEmptyResult extends UserDiscoveryState {}
