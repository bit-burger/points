import 'notification_type.dart';

/// Represents a notification, with also capabilities for formatting a string,
/// if provided the names of the referenced people in the [Notification]
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

  /// Format a string from the message data, if given [otherName]
  String getNotificationMessage([String? otherName]) {
    switch (type) {
      case NotificationType.systemMessage:
        return messageData["message"];
      case NotificationType.changedRelation:
        final changeType = messageData["change_type"];
        return _firstName(otherName) +
            " " +
            (changeType == "cancelled"
                ? "cancelled their friend request to"
                : changeType) +
            " " +
            _secondName(otherName);
      case NotificationType.pointsMilestone:
        return _firstName(otherName) +
            " ha${firstActorId == selfId ? "ve" : "s"} "
                "reached ${messageData["amount"]} point${messageData["amount"] == 1 ? "" : "s"}";
      case NotificationType.gavePoints:
        return _firstName(otherName) +
            " gave " +
            _secondName(otherName) +
            " ${messageData["amount"]} point${messageData["amount"] == 1 ? "" : "s"}";
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
