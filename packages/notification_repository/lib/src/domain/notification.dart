class Notification {
  final int id;
  final String selfId;
  final String? firstActorId;
  final String? secondActorId;
  final String type;
  final Map<String, dynamic> messageData;
  final bool hasRead;
  final DateTime createdAt;

  Notification(
    this.id,
    this.selfId,
    this.firstActorId,
    this.secondActorId,
    this.type,
    this.messageData,
    this.hasRead,
    this.createdAt,
  );

  String? getUnknownUserId() {
    if (selfId == firstActorId) {
      return secondActorId;
    }
    return firstActorId;
  }

  String getNotificationMessage(String otherName) {
    return messageData.toString();
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      json['id'],
      json['user_id'],
      json['first_actor'],
      json['second_actor'],
      json['notification_type'],
      json['message_data'],
      json['has_read'],
      DateTime.parse(json['created_at']),
    );
  }
}
