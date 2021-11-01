part of 'relations_repository.dart';

abstract class IPointsRelationsRepository {
  Stream<UserRelations> get relationsStream;

  void close();

  void accept(String id);

  void block(String id);

  void reject(String id);

  void request(String id);

  void takeBackRequest(String id);

  void unblock(String id);

  void unfriend(String id);
}
