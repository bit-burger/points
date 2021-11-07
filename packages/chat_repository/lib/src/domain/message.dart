enum Sender {
  self,
  other,
}

class Message {
  final int id;
  final DateTime timestamp;
  final String content;
  final Sender sender;

  Message(this.id, this.timestamp, this.content, this.sender);

  @override
  bool operator ==(Object other) =>
      other is Message &&
      other.id == id &&
      other.timestamp == timestamp &&
      other.content == content &&
      other.sender == sender;

  factory Message.fromJson(Map<String, dynamic> json, String selfId) {
    return Message(
      json["id"],
      json["created_at"],
      json["content"],
      json["sender"] == selfId ? Sender.self : Sender.other,
    );
  }
}
