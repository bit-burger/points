import '../domain/message.dart';
import '../domain/chat.dart';

/// Repository for chatting and getting chat notifications
abstract class IChatRepository {
  /// [Message]s of all chats except from the chat
  /// that is listened to (if there is one)
  Stream<Message> get messagesNotificationStream;

  /// [Message]s from a specific chat
  /// that has to be configured via [listenToSpecificChat]
  Stream<Chat>? get messagesFromSpecificChat;

  /// Send message to chat with the chat_id [chatId].
  ///
  /// Will throw all errors
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
  });

  /// Listens to a specific chat with the [chatId]
  /// and sets the [messagesFromSpecificChat] accordingly.
  ///
  /// If there is already a chat being listened,
  /// [stopListeningToSpecificChat] will be called automatically.
  ///
  /// [startMaxMessageCount] is how many messages should initially be fetched,
  /// if you want to fetch more call [fetchMoreMessages]
  ///
  /// Will add all errors to the [messagesFromSpecificChat]
  void listenToSpecificChat(String chatId, {int startMaxMessageCount = 30});

  /// If listening to a specific chat,
  /// call this method to fetch more messages in the timeline.
  /// A new event will be added to the stream,
  /// which will include the new and old messages,
  /// after the old messages have been fetched.
  ///
  /// Will add all errors to the [messagesFromSpecificChat]
  void fetchMoreMessages({int howMany = 20});

  /// Stop listening to the specific chat if there is one
  void stopListeningToSpecificChat();

  /// Cleanup
  void close();
}
