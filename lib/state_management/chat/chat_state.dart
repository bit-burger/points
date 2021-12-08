part of 'chat_cubit.dart';

@immutable
abstract class ChatState {}

class InitialChatState extends ChatState {}

class MessagesFirstFetchLoading extends ChatState {}

class MessagesData extends ChatState {
  final List<Message> messages;
  final bool allMessagesFetched;
  final User self;
  final RelatedUser other;

  String get selfUserId => self.id;

  MessagesData({
    required this.messages,
    required this.allMessagesFetched,
    required this.self,
    required this.other,
  });

  MessagesData copyWith({
    List<Message>? messages,
    bool? allMessagesFetched,
    User? self,
    RelatedUser? other,
  }) {
    return MessagesData(
      messages: messages ?? this.messages,
      allMessagesFetched: allMessagesFetched ?? this.allMessagesFetched,
      self: self ?? this.self,
      other: other ?? this.other,
    );
  }
}

class ChatClosed extends ChatState {}
