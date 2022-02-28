part of 'friend_cubit.dart';

@immutable
abstract class FriendState {}

class FriendInitialState extends FriendState {}

class FriendDataState extends FriendState {
  final RelatedUser data;

  FriendDataState(this.data);
}

class FriendUnfriendedState extends FriendState {}
