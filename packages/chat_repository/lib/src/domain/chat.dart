import 'message.dart';

class Chat {
  final List<Message> messages;
  final bool allMessagesFetched;

  Chat(this.messages, this.allMessagesFetched);

  Chat copyWithMessages(List<Message> messages) {
    return Chat(messages, allMessagesFetched);
  }
}
