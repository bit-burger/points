import 'package:chat_repository/src/domain/message.dart';
import 'package:matcher/matcher.dart';

/// Match a message for testing (without timestamps)
class MessageMatcher extends Matcher {
  final String chatId;
  final String content;
  final String senderId;
  final String receiverId;

  MessageMatcher({
    required this.chatId,
    required this.content,
    required this.senderId,
    required this.receiverId,
  });

  @override
  Description describe(Description description) {
    return description;
  }

  @override
  bool matches(item, Map matchState) =>
      item is Message &&
      item.chatId == chatId &&
      item.content == content &&
      item.senderId == senderId &&
      item.receiverId == receiverId;

  MessageMatcher switchSenderReceiver() {
    return MessageMatcher(
      chatId: chatId,
      content: content,
      senderId: receiverId,
      receiverId: senderId,
    );
  }

  MessageMatcher copyWith({
    String? chatId,
    String? content,
    String? senderId,
    String? receiverId,
  }) {
    return MessageMatcher(
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      senderId: receiverId ?? this.receiverId,
      receiverId: senderId ?? this.senderId,
    );
  }
}
