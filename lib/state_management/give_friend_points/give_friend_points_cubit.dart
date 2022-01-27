import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:user_repositories/profile_repository.dart';
import 'package:user_repositories/relations_repository.dart';

part 'give_friend_points_state.dart';

class GiveFriendPointsCubit extends Cubit<GiveFriendPointsState> {
  final IRelationsRepository relationsRepository;
  final IProfileRepository profileRepository;
  late final StreamSubscription _sub1, _sub2;

  GiveFriendPointsCubit({
    required this.relationsRepository,
    required this.profileRepository,
  }) : super(GiveFriendPointsInitial());

  void selectFriend({required String friendId}) {
    final initialGives = profileRepository.currentProfile!.gives;
    if (initialGives == 0) {
      return emit(GiveFriendsPointsFinished());
    }
    final initialFriends = relationsRepository.currentUserRelations!.friends;
    // Set up first hearing
    final friendIndex = initialFriends.indexWhere(
      (friend) => friend.id == friendId,
    );
    if (friendIndex == -1) {
      return emit(GiveFriendsPointsFinished());
    }
    emit(
      GiveFriendPointsData(
        friend: initialFriends[friendIndex],
        howManyPoints: max(1, initialGives ~/ 2),
        howManyPointsLimit: initialGives,
      ),
    );
    // start listening
    _sub1 = relationsRepository.relationsStream.listen((userRelations) {
      if (state is GiveFriendsPointsFinished) {
        return;
      }
      final friendIndex = userRelations.friends.indexWhere(
        (friend) => friend.id == friendId,
      );
      if (friendIndex == -1) {
        return emit(GiveFriendsPointsFinished());
      }
      final oldState = state as GiveFriendPointsData;
      emit(
        oldState.copyWith(friend: userRelations.friends[friendIndex]),
      );
    });
    _sub2 = profileRepository.profileStream.listen((profile) {
      if (state is GiveFriendsPointsFinished) {
        return;
      }
      if (profile.gives == 0) {
        return emit(GiveFriendsPointsFinished());
      }
      final oldState = state as GiveFriendPointsData;
      if (oldState.howManyPoints > profile.gives) {
        emit(
          oldState.copyWith(
            howManyPoints: profile.gives,
            howManyPointsLimit: profile.gives,
          ),
        );
      } else {
        emit(
          oldState.copyWith(howManyPointsLimit: profile.gives),
        );
      }
    });
  }

  void setHowManyPoints({required int newAmount}) {
    final oldState = state as GiveFriendPointsData;
    emit(
      oldState.copyWith(howManyPoints: newAmount),
    );
  }

  void givePoints() {
    final currentState = state as GiveFriendPointsData;
    relationsRepository.givePoints(
      currentState.friend.id,
      currentState.howManyPoints,
    );
    emit(GiveFriendsPointsFinished());
  }

  @override
  Future<void> close() async {
    await _sub1.cancel();
    await _sub2.cancel();
    return super.close();
  }
}
