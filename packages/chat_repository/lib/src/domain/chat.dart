import 'message.dart';

/// Represents a chat and all the messages that have already been loaded
class Chat {
  final List<Message> messages;
  final bool allMessagesFetched;

  Chat(this.messages, this.allMessagesFetched);

  Chat copyWithMessages(List<Message> messages) {
    return Chat(messages, allMessagesFetched);
  }
}
