import 'user.dart';

class UserRelations {
  final List<User> friends;
  final List<User> requests;
  final List<User> pending;
  final List<User> blocked;

  UserRelations(this.friends, this.requests, this.pending, this.blocked);
}
