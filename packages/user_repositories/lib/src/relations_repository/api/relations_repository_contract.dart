import '../domain/user_relations.dart';

abstract class IRelationsRepository {
  Stream<UserRelations> get relationsStream;

  Future<void> accept(String id);

  Future<void> block(String id);

  Future<void> reject(String id);

  Future<void> request(String id);

  Future<void> cancelRequest(String id);

  Future<void> unblock(String id);

  Future<void> unfriend(String id);

  void close();
}
