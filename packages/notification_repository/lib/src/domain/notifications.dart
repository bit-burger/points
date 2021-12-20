import 'notification.dart';

class Notifications {
  final List<Notification> notifications;
  final bool allNotificationsFetched;

  Notifications(this.notifications, this.allNotificationsFetched);

  Notifications copyWith({
    Iterable<Notification>? olderNotifications,
    Iterable<Notification>? earlierNotifications,
    Notification? earlierNotification,
    bool? allNotificationsFetched,
  }) {
    final newNotifications = [
      ...?earlierNotifications,
      ...notifications,
      ...?olderNotifications,
    ];
    if (earlierNotification != null) {
      newNotifications.insert(0, earlierNotification);
    }
    return Notifications(
      newNotifications,
      allNotificationsFetched ?? this.allNotificationsFetched,
    );
  }
}
