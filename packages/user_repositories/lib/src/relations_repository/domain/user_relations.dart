import '../../domain_shared/user.dart';

class UserRelations {
  final List<User> friends;

  /// All the requests to the RootUser
  final List<User> requests;

  /// All requests the RootUser has sent
  final List<User> pending;

  /// All Users that the RootUser blocked
  final List<User> blocked;

  /// All Users that have blocked the RootUser
  final List<User> blockedBy;

  UserRelations(
      this.friends, this.requests, this.pending, this.blocked, this.blockedBy);

  factory UserRelations.empty() {
    return UserRelations([], [], [], [], []);
  }

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
