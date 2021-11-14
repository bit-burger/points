part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileExistsState extends ProfileState {
  final User profile;

  ProfileExistsState(this.profile);
}
