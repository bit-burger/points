part of 'relations_repository.dart';

abstract class IPointsRelationsRepository {
  Stream<UserRelations> get relationsStream;

  Future<void> accept(String id);

  Future<void> block(String id);

  Future<void> reject(String id);

  Future<void> request(String id);

  Future<void> takeBackRequest(String id);

  Future<void> unblock(String id);

  Future<void> unfriend(String id);

  void close();
}
