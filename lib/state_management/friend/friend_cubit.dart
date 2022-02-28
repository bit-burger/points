import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:user_repositories/relations_repository.dart';
import '../../pages/friend/friend_page.dart';

part 'friend_state.dart';

/// Listen to the profile of a specific friend.
///
/// Used only in the [FriendPage].
class FriendCubit extends Cubit<FriendState> {
  late final StreamSubscription _sub;
  final IRelationsRepository relationsRepository;

  FriendCubit(
    this.relationsRepository,
  ) : super(FriendInitialState());

  void loadFriendData({required String friendId}) {
    _getInitialFriendData(friendId);
    _startListening(friendId);
  }

  /// Emits the [FriendDataState] from the [IRelationsRepository.currentUserRelations],
  /// also asserts that the [IRelationsRepository.currentUserRelations] are not null
  void _getInitialFriendData(String friendId) {
    final friendIndex =
        relationsRepository.currentUserRelations!.friends.indexWhere(
      (friend) => friend.id == friendId,
    );
    emit(
      FriendDataState(
        relationsRepository.currentUserRelations!.friends[friendIndex],
      ),
    );
  }

  /// Start listening to changes of the friend in the [RelationsRepository].
  ///
  /// If the friend is not found in the [UserRelations.friends],
  /// the [FriendUnfriendedState] will be emitted
  void _startListening(String friendId) {
    _sub = relationsRepository.relationsStream.listen((userRelations) {
      final oldFriend =
          state is FriendDataState ? (state as FriendDataState).data : null;
      if (oldFriend == null) {
        return;
      }
      final friendIndex = userRelations.friends.indexWhere(
        (friend) => friend.id == friendId,
      );
      final newFriend =
          friendIndex == -1 ? null : userRelations.friends[friendIndex];
      if (newFriend == null) {
        emit(FriendUnfriendedState());
      } else {
        // Check if properties of friend have changed
        if (oldFriend != newFriend) {
          emit(FriendDataState(newFriend));
        }
      }
    });
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
