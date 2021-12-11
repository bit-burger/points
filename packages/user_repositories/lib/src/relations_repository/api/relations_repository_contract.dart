import 'package:user_repositories/relations_repository.dart';

/// Change and view updates of relations in points
abstract class IRelationsRepository {
  /// Updates of relations
  Stream<UserRelations> get relationsStream;

  /// Current relations (last that were added to the [relationsStream]
  UserRelations? get currentUserRelations;

  /// All mutations of relations can throw a [PointsIllegalRelationError]

  /// Accept friend request
  void accept(String id);

  /// Block user
  void block(String id);

  /// Reject friend request
  void reject(String id);

  /// Send friend request
  void request(String id);

  /// Cancel a already sent friend request
  void cancelRequest(String id);

  /// Unblock user
  void unblock(String id);

  /// Unfriend user
  void unfriend(String id);

  /// Cleanup
  void close();
}
