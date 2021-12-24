import 'package:notification_repository/notification_repository.dart';
import 'package:test/test.dart';

class NotificationMatcher extends Matcher {
  final String selfId;
  final String? firstActorId;
  final String? secondActorId;
  final NotificationType type;
  final Map<String, dynamic> messageData;
  final bool hasRead;

  NotificationMatcher({
    required this.selfId,
    String? firstActorId,
    this.secondActorId,
    required this.type,
    required this.messageData,
    this.hasRead = false,
  }) : this.firstActorId = firstActorId ?? selfId;

  factory NotificationMatcher.first(String selfId) {
    return NotificationMatcher(
      selfId: selfId,
      messageData: {"message": "Hi, thanks for joining points"},
      type: NotificationType.systemMessage,
    );
  }

  @override
  Description describe(Description description) {
    return description;
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (item is! Notification) {
      return false;
    }

    expect(item.messageData, messageData);

    return item.selfId == selfId &&
        item.firstActorId == firstActorId &&
        item.secondActorId == secondActorId &&
        item.type == type &&
        item.hasRead == hasRead;
  }

  NotificationMatcher copyWith({
    String? selfId,
    String? firstActorId,
    String? secondActorId,
    NotificationType? type,
    Map<String, dynamic>? messageData,
    bool? hasRead,
  }) {
    return NotificationMatcher(
      selfId: selfId ?? this.selfId,
      firstActorId: firstActorId ?? this.firstActorId,
      secondActorId: secondActorId ?? this.secondActorId,
      type: type ?? this.type,
      messageData: messageData ?? this.messageData,
      hasRead: hasRead ?? this.hasRead,
    );
  }
}
