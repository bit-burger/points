class Message {
  final String chatId;
  final DateTime timestamp;
  final String content;
  final String senderId;
  final String receiverId;

  Message(this.chatId, this.timestamp, this.content, this.senderId,
      this.receiverId);

  @override
  bool operator ==(Object other) =>
      other is Message &&
      other.chatId == chatId &&
      other.timestamp == timestamp &&
      other.content == content &&
      other.senderId == senderId;

  factory Message.fromJson(Map<String, dynamic> json, {String? chatId}) {
    return Message(
      chatId ?? json["chat_id"],
      DateTime.parse(json["created_at"]),
      json["content"],
      json["sender"],
      json["receiver"],
    );
  }

  @override
  String toString() {
    return 'Message{'
        'chatId: $chatId, '
        'content: $content, '
        'senderId: $senderId, '
        'receiverId: $receiverId'
        '}';
  }

  @override
  int get hashCode => Object.hash(
        chatId,
        timestamp,
        content,
        senderId,
      );
}
