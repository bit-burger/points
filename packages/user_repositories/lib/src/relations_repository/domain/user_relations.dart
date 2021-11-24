import '../../domain_shared/user.dart';

/// Represents the relations a user in points has
class UserRelations {
  /// All friends of the user
  final List<User> friends;

  /// All the requests to the user
  final List<User> requests;

  /// All requests the user has sent
  final List<User> pending;

  /// All Users that the user blocked
  final List<User> blocked;

  /// All users that have blocked this user
  final List<User> blockedBy;

  UserRelations(
      this.friends, this.requests, this.pending, this.blocked, this.blockedBy);

  factory UserRelations.empty() {
    return UserRelations([], [], [], [], []);
  }

  List<User> get all => friends + requests + pending + blocked + blockedBy;

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
