import '../domain/message.dart';

abstract class IChatRepository {
  Stream<List<Message>> messageStreamToUserId(
      {required String otherId, int startingLimit = 20});
}
