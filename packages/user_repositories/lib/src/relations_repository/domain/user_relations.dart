import 'related_user.dart';

/// Represents the relations a user in points has
class UserRelations {
  /// All friends of the user
  final List<RelatedUser> friends;

  /// All the requests to the user
  final List<RelatedUser> requests;

  /// All requests the user has sent
  final List<RelatedUser> pending;

  /// All Users that the user blocked
  final List<RelatedUser> blocked;

  /// All users that have blocked this user
  final List<RelatedUser> blockedBy;

  UserRelations(
      this.friends, this.requests, this.pending, this.blocked, this.blockedBy);

  factory UserRelations.empty() {
    return UserRelations([], [], [], [], []);
  }

  List<RelatedUser> get all =>
      friends + requests + pending + blocked + blockedBy;

  int get relationsCount => normalRelationsCount + blockedRelationsCount;

  int get normalRelationsCount =>
      friends.length + requests.length + pending.length;

  int get blockedRelationsCount => blocked.length + blockedBy.length;

  @override
  bool operator ==(Object other) =>
      other is UserRelations &&
      other.friends.equals(friends) &&
      other.requests.equals(requests) &&
      other.pending.equals(pending) &&
      other.blocked.equals(blocked) &&
      other.blockedBy.equals(blockedBy);

  @override
  int get hashCode => Object.hash(
        friends,
        requests,
        pending,
        blocked,
        blockedBy,
      );

  @override
  String toString() {
    return "friends: $friends\n"
        "requests: $requests\n"
        "pending: $pending\n"
        "blocked: $blocked\n"
        "blockedBy: $blockedBy";
  }
}

extension on List {
  bool equals(List list) {
    if (this.length != list.length) return false;
    for (int i = 0; i < list.length; i++) {
      if (this[i] != list[i]) {
        return false;
      }
    }
    return true;
  }
}
