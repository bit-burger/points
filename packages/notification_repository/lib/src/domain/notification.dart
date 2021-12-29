import 'notification_type.dart';

class Notification {
  final int id;
  final String selfId;
  final String? firstActorId;
  final String? secondActorId;
  final NotificationType type;
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

  String? get unknownUserId {
    if (selfId == firstActorId) {
      return secondActorId;
    }
    return firstActorId;
  }

  String _firstName(String? otherName) {
    if (firstActorId == selfId) {
      return "You";
    }
    return otherName!;
  }

  String _secondName(String? otherName) {
    if (secondActorId == selfId) {
      return "you";
    }
    return otherName!;
  }

  String getNotificationMessage([String? otherName]) {
    switch (type) {
      case NotificationType.systemMessage:
        return messageData["message"];
      case NotificationType.changedRelation:
        final changeType = messageData["change_type"];
        return _firstName(otherName) +
            " " +
            (changeType == "cancelled"
                ? "cancelled the friend request of"
                : changeType) +
            " " +
            _secondName(otherName);
      case NotificationType.pointsMilestone:
        return _firstName(otherName) +
            " ha${firstActorId == selfId ? "ve" : "s"} "
                "reached ${messageData["points"]} points";
      case NotificationType.gavePoints:
        return _firstName(otherName) +
            " gave " +
            _secondName(otherName) +
            " ${messageData["points"]} points";
      case NotificationType.receivedMessage:
      case NotificationType.profileUpdate:
      default:
        throw UnimplementedError();
    }
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      json['id'],
      json['user_id'],
      json['first_actor'],
      json['second_actor'],
      notificationTypeFromString(json['notification_type']),
      json['message_data'],
      json['has_read'],
      DateTime.parse(json['created_at']),
    );
  }
}
