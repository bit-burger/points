import 'notification.dart';

/// Represents the notifications the user has loaded
class Notifications {
  final List<Notification> _notifications;
  final bool allNotificationsFetched;
  // needed, because the NotificationRepository
  // doesn't clone the List of notifications,
  // so to not modify the original
  List<Notification> get notifications => [..._notifications];

  Notifications(
    List<Notification> notifications,
    this.allNotificationsFetched,
  ) : _notifications = notifications;

  Notifications copyWith({
    Iterable<Notification>? olderNotifications,
    Iterable<Notification>? earlierNotifications,
    Notification? earlierNotification,
    bool? allNotificationsFetched,
  }) {
    final newNotifications = [
      ...?earlierNotifications,
      ..._notifications,
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
