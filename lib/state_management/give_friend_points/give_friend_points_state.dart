part of 'give_friend_points_cubit.dart';

@immutable
abstract class GiveFriendPointsState {}

class GiveFriendPointsInitial extends GiveFriendPointsState {}

class GiveFriendPointsData extends GiveFriendPointsState {
  final RelatedUser friend;
  final int howManyPoints;
  final int howManyPointsLimit;

  bool get lastGive => howManyPointsLimit == 1;

  GiveFriendPointsData({
    required this.friend,
    required this.howManyPoints,
    required this.howManyPointsLimit,
  });

  GiveFriendPointsData copyWith({
    RelatedUser? friend,
    int? howManyPoints,
    int? howManyPointsLimit,
  }) {
    return GiveFriendPointsData(
      friend: friend ?? this.friend,
      howManyPoints: howManyPoints ?? this.howManyPoints,
      howManyPointsLimit: howManyPointsLimit ?? this.howManyPointsLimit,
    );
  }
}

class GiveFriendsPointsFinished extends GiveFriendPointsState {}
