import 'package:notification_repository/notification_repository.dart';
import 'package:test/test.dart';

class NotificationMatcher extends Matcher {
  final String selfId;
  final String? firstActorId;
  final String? secondActorId;
  final String type;
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
      type: "system_message",
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
    return item.selfId == selfId &&
        item.firstActorId == firstActorId &&
        item.secondActorId == secondActorId &&
        item.type == type &&
        item.messageData == messageData &&
        item.hasRead == hasRead;
  }
}
